## ----setup, include=FALSE------------------------------------------------
library(kirby21.smri)
library(kirby21.base)
library(plyr)
library(dplyr)
library(EveTemplate)
library(neurobase)
library(ANTsR)
library(ggplot2)
library(reshape2)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")

## ---- eval = FALSE-------------------------------------------------------
## packages = installed.packages()
## packages = packages[, "Package"]
## if (!"kirby21.base" %in% packages) {
##   devtools::install_github("muschellij2/kirby21.base")
## }
## if (!"kirby21.smri" %in% packages) {
##   devtools::install_github("muschellij2/kirby21.smri")
## }
## if (!"EveTemplate" %in% packages) {
##   devtools::install_github("jfortin1/EveTemplate")
## }

## ----data----------------------------------------------------------------
library(kirby21.smri)
library(kirby21.base)
run_mods = c("T1", "T2", "FLAIR")
fnames = get_image_filenames_list_by_visit(
  ids = 113, 
  modalities = run_mods, 
  visits = c(1,2 ))
visit_1 = fnames$`1`$`113`
visit_2 = fnames$`2`$`113`
mods = visit_1 %>% nii.stub(bn = TRUE) %>% 
  strsplit("-") %>% 
  sapply(dplyr::last)
names(visit_1) = names(visit_2) = mods
visit_1 = visit_1[run_mods]
visit_2 = visit_2[run_mods]

## ----preprocess_within, cache = FALSE------------------------------------
library(extrantsr)
outfiles = nii.stub(visit_1, bn = TRUE)
proc_files = paste0(outfiles, "_proc.nii.gz")
names(proc_files) = names(outfiles)
if (!all(file.exists(proc_files))) {
  extrantsr::preprocess_mri_within(
    files = visit_1,
    outfiles = proc_files,
    correct = TRUE,
    retimg = FALSE,
    correction = "N4")
}

## ----read_proc_images, cache = FALSE-------------------------------------
proc_imgs = lapply(proc_files, readnii)

## ----plot_images---------------------------------------------------------
lapply(proc_imgs, ortho2)

## ----t1_ss, cache = FALSE------------------------------------------------
outfile = nii.stub(visit_1["T1"], bn = TRUE)
outfile = paste0(outfile, "_SS.nii.gz")
if (!file.exists(outfile)) {
  ss = extrantsr::fslbet_robust(visit_1["T1"], 
    remover = "double_remove_neck",
    outfile = outfile)
} else {
  ss = readnii(outfile)
}

## ----apply_mask, cache = FALSE-------------------------------------------
mask = ss > 0
proc_imgs = lapply(proc_imgs, mask_img, mask = mask)
dd = dropEmptyImageDimensions(mask, other.imgs = proc_imgs)
mask = dd$outimg
proc_imgs = dd$other.imgs

## ----plot_masked_images--------------------------------------------------
lapply(proc_imgs, ortho2)

## ----n4_ss_images, cache = FALSE-----------------------------------------
n4_proc_imgs = plyr::llply(
  proc_imgs, 
  bias_correct, 
  correction = "N4", 
  mask = mask,
  retimg = TRUE,
  .progress = "text")

## ----write_n4_ss, cache = FALSE------------------------------------------
outfiles = nii.stub(visit_1, bn = TRUE)
outfiles = paste0(outfiles, "_proc_N4_SS.nii.gz")
if (!all(file.exists(outfiles))) {
  mapply(function(img, outfile) {
    writenii(img, filename = outfile)
  }, n4_proc_imgs, outfiles)
}

## ----intensity_normalize, cache = FALSE----------------------------------
norm_imgs = plyr::llply(
  n4_proc_imgs, 
  zscore_img,
  margin = NULL,
  centrality = "mean",
  variability = "sd",
  mask = mask,
  .progress = "text")

## ----make_df, cache = FALSE----------------------------------------------
df = sapply(norm_imgs, function(x){
  x[ mask == 1 ]
})
long = reshape2::melt(df)
colnames(long) = c("ind", "sequence", "value")
long$ind = NULL
df = data.frame(df)

## ----make_dists, cache = TRUE--------------------------------------------
ggplot(long, aes(x = value, colour = factor(sequence))) + 
  geom_line(stat = "density")

## ----make_hex, cache = TRUE----------------------------------------------
g = ggplot(df) + stat_binhex()
g + aes(x = T1, y = T2)
g + aes(x = T1, y = FLAIR)
g + aes(x = T2, y = FLAIR)

## ----eve, cache = FALSE--------------------------------------------------
outfiles = nii.stub(visit_1, bn = TRUE)
norm_reg_files = paste0(outfiles, "_norm_eve.nii.gz")
names(norm_reg_files) = names(outfiles)
eve_brain_fname = getEvePath("Brain")

if ( !all( file.exists(norm_reg_files) )) {
  reg = registration(
    filename = n4_proc_imgs$T1, 
    template.file = eve_brain_fname,
    other.files = norm_imgs,
    other.outfiles = norm_reg_files,
    interpolator = "LanczosWindowedSinc",
    typeofTransform = "SyN")
} 

## ----eve_res, cache = FALSE----------------------------------------------
eve_brain = readnii(eve_brain_fname)
eve_brain_mask = readEve(what = "Brain_Mask")
norm_reg_imgs = lapply(norm_reg_files, readnii)
norm_reg_imgs = lapply(norm_reg_imgs, mask_img, mask = eve_brain_mask)

## ----eve_res_plot, cache = TRUE------------------------------------------
lapply(norm_reg_imgs, double_ortho, x = eve_brain)

## ------------------------------------------------------------------------
devtools::session_info()

