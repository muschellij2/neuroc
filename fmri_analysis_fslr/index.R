## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")

## ----libs, cache = FALSE-------------------------------------------------
library(methods)
library(fslr)
library(neurobase)
library(extrantsr)

## ---- eval = FALSE-------------------------------------------------------
## packages = installed.packages()
## packages = packages[, "Package"]
## if (!"kirby21.base" %in% packages) {
##   devtools::install_github("muschellij2/kirby21.base")
## }
## if (!"kirby21.fmri" %in% packages) {
##   devtools::install_github("muschellij2/kirby21.fmri")
## }

## ----data----------------------------------------------------------------
library(kirby21.fmri)
library(kirby21.base)
fnames = get_image_filenames_df(ids = 113, 
                    modalities = c("T1", "fMRI"), 
                    visits = c(1),
                    long = FALSE)
t1_fname = fnames$T1[1]
fmri_fname = fnames$fMRI[1]
base_fname = nii.stub(fmri_fname, bn = TRUE)

## ----par_data------------------------------------------------------------
library(R.utils)
par_file = system.file("visit_1/113/113-01-fMRI.par.gz", 
                       package = "kirby21.fmri")
# unzip it
con = gunzip(par_file, temporary = TRUE, 
             remove = FALSE, overwrite = TRUE)
info = readLines(con = con)
info[11:23]

## ----fmri, cache = TRUE--------------------------------------------------
fmri = readnii(fmri_fname)
ortho2(fmri, w = 1, add.orient = FALSE)
rm(list = "fmri") # just used for cleanup 

## ----subset_run, eval = TRUE, cache = FALSE------------------------------
fmri = readnii(fmri_fname)
tr = 2 # 2 seconds
first_scan = floor(10.0 / tr) + 1 # 10 seconds "stabilization of signal"
sub_fmri = subset_4d(fmri, first_scan:ntim(fmri))

## ----slice_timer, cache = FALSE------------------------------------------
library(fslr)
scorr_fname = paste0(base_fname, "_scorr.nii.gz")
if (!file.exists(scorr_fname)) {
  scorr = fsl_slicetimer(file = sub_fmri, 
                 outfile = scorr_fname, 
                 tr = 2, direction = "z", acq_order = "contiguous",
                 indexing = "up")
} else {
  scorr = readnii(scorr_fname)
}

## ----mcflirt, cache = FALSE----------------------------------------------
moco_fname = paste0(base_fname, 
                    "_motion_corr.nii.gz")
par_file = paste0(nii.stub(moco_fname), ".par")
avg_fname = paste0(base_fname, 
                   "_avg.nii.gz")
if (!file.exists(avg_fname)) {
  fsl_maths(file = sub_fmri, 
            outfile = avg_fname,
            opts = "-Tmean")
}

if (!all(file.exists(c(moco_fname, par_file)))) {
  moco_img = mcflirt(
    file = sub_fmri, 
    outfile = moco_fname,
    verbose = 2,
    opts = paste0("-reffile ", avg_fname, " -plots")
  )
} else {
  moco_img = readnii(moco_fname)
}
moco_params = readLines(par_file)
moco_params = strsplit(moco_params, split = " ")
moco_params = sapply(moco_params, function(x) {
  as.numeric(x[ !(x %in% "")])
})
moco_params = t(moco_params)
colnames(moco_params) = paste0("MOCOparam", 1:ncol(moco_params))
head(moco_params)

## ----ts_run, echo = TRUE, cache = FALSE----------------------------------
moco_avg_img = fslmaths(moco_fname, opts = "-Tmean")
maskImage = oMask(moco_avg_img, 
    mean(moco_avg_img), 
    Inf, cleanup = 2)
mask_fname = paste0(base_fname, "_mask.nii.gz")
writenii(maskImage, filename = mask_fname)

bet_mask = fslbet(moco_avg_img) > 0
bet_mask_fname = paste0(base_fname, "_bet_mask.nii.gz")
writenii(bet_mask, filename = bet_mask_fname)

## ----plot_masks, cache = TRUE--------------------------------------------
double_ortho(moco_avg_img, maskImage, 
  col.y = "white")
double_ortho(moco_avg_img, bet_mask, 
  col.y = "white")
ortho_diff( moco_avg_img, roi = maskImage, pred = bet_mask )

## ----boldmat, cache=FALSE------------------------------------------------
moco_avg_img[maskImage == 0] = 0
boldMatrix = img_ts_to_matrix(
    moco_img)
boldMatrix = t(boldMatrix)
boldMatrix = boldMatrix[ , maskImage == 1]

## ----compute_dvars, echo = TRUE------------------------------------------
dvars = ANTsR::computeDVARS(boldMatrix)
dMatrix = apply(boldMatrix, 2, diff)
dMatrix = rbind(rep(0, ncol(dMatrix)), dMatrix)
my_dvars = sqrt(rowMeans(dMatrix^2))
head(cbind(dvars = dvars, my_dvars = my_dvars))
print(mean(my_dvars))

## ----compute_fd, echo = TRUE---------------------------------------------
mp = moco_params
mp[, 1:3] = mp[, 1:3] * 50
mp = apply(mp, 2, diff)
mp = rbind(rep(0, 6), mp)
mp = abs(mp)
fd = rowSums(mp)

## ----moco_run_plot, echo = TRUE, cache = FALSE, fig.height = 4, fig.width= 8----
mp = moco_params
mp[, 1:3] = mp[, 1:3] * 50
r = range(mp)
plot(mp[,1], type = "l", xlab = "Scan Number", main = "Motion Parameters",
     ylab = "Displacement (mm)",
     ylim = r * 1.25, 
     lwd = 2,
     cex.main = 2,
     cex.lab = 1.5,
     cex.axis = 1.25)
for (i in 2:ncol(mp)) {
  lines(mp[, i], col = i)
}
rm(list = "mp")

## ----ts_heatmap, echo = TRUE, fig.height = 3.5, fig.width = 8------------
library(RColorBrewer)
library(matrixStats)
rf <- colorRampPalette(rev(brewer.pal(11,'Spectral')))
r <- rf(32)
mat = scale(boldMatrix)
image(x = 1:nrow(mat), 
      y = 1:ncol(mat), 
      mat, useRaster = TRUE, 
      col = r,
      xlab = "Scan Number", ylab = "Voxel",
      main = paste0("Dimensions: ", 
                    dim(mat)[1], "×", dim(mat)[2]),
     cex.main = 2,
     cex.lab = 1.5,
     cex.axis = 1.25)
rmeans = rowMeans(mat)
bad_ind = which.max(rmeans)
print(bad_ind)
abline(v = bad_ind)
sds = rowSds(mat)
print(which.max(sds))
rm(list = "mat")

## ----plot_bad_ortho, echo = TRUE, dependson="ts_heatmap"-----------------
library(animation)
ani.options(autobrowse = FALSE)
gif_name = "bad_dimension.gif"
if (!file.exists(gif_name)) {
  arr = as.array(moco_img)
  pdim = pixdim(moco_img)
  saveGIF({
    for (i in seq(bad_ind - 1, bad_ind + 1)) {
      ortho2(arr[,,,i], pdim = pdim, text = i)
    }
  }, movie.name = gif_name)
}

## ---- cache = FALSE------------------------------------------------------
devtools::session_info()

