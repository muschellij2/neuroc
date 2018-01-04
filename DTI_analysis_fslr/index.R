## ----setup, include=FALSE------------------------------------------------
library(knitr)
library(kirby21.dti)
library(kirby21.base)
library(plyr)
library(dplyr)
library(fslr)
library(extrantsr)
library(EveTemplate)
library(neurobase)
library(ANTsR)
library(ggplot2)
library(reshape2)

## ---- eval = FALSE-------------------------------------------------------
## packages = installed.packages()
## packages = packages[, "Package"]
## if (!"kirby21.base" %in% packages) {
##   source("https://neuroconductor.org/neurocLite.R")
##   neuroc_install("kirby21.base")
## }
## if (!"kirby21.dti" %in% packages) {
##   source("https://neuroconductor.org/neurocLite.R")
##   neuroc_install("kirby21.dti")
## }

## ----data----------------------------------------------------------------
library(kirby21.dti)
library(kirby21.base)
fnames = get_image_filenames_df(ids = 113, 
                    modalities = c("T1", "DTI"), 
                    visits = c(1),
                    long = FALSE)
t1_fname = fnames$T1[1]
dti_fname = fnames$DTI[1]
base_fname = nii.stub(dti_fname, bn = TRUE)
dti_data = get_dti_info_filenames(
  ids = 113, 
  visits = c(1))
b_fname = dti_data$fname[ dti_data$type %in% "b"]
grad_fname = dti_data$fname[ dti_data$type %in% "grad"]

## ----b_values------------------------------------------------------------
b_vals = readLines(b_fname)
b_vals = as.numeric(b_vals)
b0 = which(b_vals == 0)[1]

b_vecs = read.delim(grad_fname, header = FALSE)
stopifnot(all(is.na(b_vecs$V4)))
b_vecs$V4 = NULL
colnames(b_vecs) = c("x", "y", "z")


## ---- cache = FALSE------------------------------------------------------
library(fslr)
print(fsl_version())

## ----check_img-----------------------------------------------------------
n_timepoints = fslval(dti_fname, "dim4")
stopifnot(nrow(b_vecs) == n_timepoints)
stopifnot(length(b_vals) == n_timepoints)

## ----eddy, cache = FALSE-------------------------------------------------
eddy_fname = paste0(base_fname, "_eddy.nii.gz")
if (!file.exists(eddy_fname)) {
  eddy = eddy_correct(
    infile = dti_fname, 
    outfile = eddy_fname, 
    retimg = TRUE, 
    reference_no = 0)
} else {
  eddy = readnii(eddy_fname)
}

## ----eddy0, cache = FALSE------------------------------------------------
dti = readnii(dti_fname)
eddy0 = extrantsr::subset_4d(eddy, b0)
dti0 = extrantsr::subset_4d(dti, b0)

## ----eddy0_plot----------------------------------------------------------
double_ortho(robust_window(eddy0), robust_window(dti0))

## ----mask, cache=FALSE---------------------------------------------------
mask_fname = paste0(base_fname, "_mask.nii.gz")
if (!file.exists(mask_fname)) {
  fsl_bet(infile = dti0, outfile = mask_fname)
} 
mask = readnii(mask_fname)

## ----bet_plot------------------------------------------------------------
ortho2(robust_window(dti0), mask, col.y = alpha("red", 0.5))

## ----dtifit, cache=FALSE-------------------------------------------------
outprefix = base_fname
suffixes = c(paste0("V", 1:3),
             paste0("L", 1:3),
             "MD", "FA", "MO", "S0")
outfiles = paste0(outprefix, "_", 
                  suffixes, get.imgext())
names(outfiles) = suffixes
if (!all(file.exists(outfiles))) {
  res = dtifit(infile = eddy_fname, 
               bvecs = as.matrix(b_vecs),
               bvals = b_vals, 
               mask = mask_fname,
               outprefix = outprefix)
}

## ----read_res, cache = FALSE---------------------------------------------
res_imgs = lapply(outfiles[c("FA", "MD")], readnii)

## ----plot_fa-------------------------------------------------------------
ortho2(res_imgs$FA)

## ----plot_md-------------------------------------------------------------
ortho2(res_imgs$MD)

## ----plot_fa_md----------------------------------------------------------
double_ortho(res_imgs$FA, res_imgs$MD)

## ----make_hex, cache = TRUE----------------------------------------------
mask = readnii(mask_fname)
df = data.frame(FA = res_imgs$FA[ mask == 1], 
                MD = res_imgs$MD[ mask == 1] )
ggplot(df, aes(x = FA, y = MD)) + stat_binhex()
rm(list = "df")
rm(list = "mask")

## ---- eval = FALSE-------------------------------------------------------
## xfibres(infile = outfile,
##         bvecs = b_vecs,
##         bvals = b_vals,
##         mask = mask_fname)

## ---- cache = FALSE------------------------------------------------------
devtools::session_info()

