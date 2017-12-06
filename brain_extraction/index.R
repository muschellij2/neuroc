## ----setup, include=FALSE------------------------------------------------
library(kirby21.fmri)
library(kirby21.base)
library(dplyr)
library(fslr)
library(neurobase)
library(ANTsR)
library(R.utils)
library(RColorBrewer)
library(matrixStats)
library(ggplot2)
library(reshape2)
library(animation)
library(zoo)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "",
                      cache.path = "index_cache/html/")

## ---- eval = FALSE-------------------------------------------------------
## source("https://neuroconductor.org/neurocLite.R")
## packages = installed.packages()
## packages = packages[, "Package"]
## if (!"kirby21.base" %in% packages) {
##   neuroc_install("kirby21.base")
## }
## if (!"kirby21.t1" %in% packages) {
##   neuroc_install("kirby21.t1")
## }

## ----data----------------------------------------------------------------
library(kirby21.t1)
library(kirby21.base)
fnames = get_image_filenames_df(ids = 113, 
                    modalities = c("T1"), 
                    visits = c(1),
                    long = FALSE)
t1_fname = fnames$T1[1]

## ----t1_plot, cache = TRUE-----------------------------------------------
t1 = readnii(t1_fname)
ortho2(t1)
rm(list = "t1")

## ----t1_naive_ss, cache = FALSE------------------------------------------
library(fslr)
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = paste0(outfile, "_SS_Naive.nii.gz")
if (!file.exists(outfile)) {
  ss_naive = fslbet(infile = t1_fname, outfile = outfile)
} else {
  ss_naive = readnii(outfile)
}

## ----t1_naive_plot, cache = TRUE-----------------------------------------
ortho2(ss_naive)

## ----t1_ss, cache = FALSE------------------------------------------------
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = paste0(outfile, "_SS.nii.gz")
if (!file.exists(outfile)) {
  ss = extrantsr::fslbet_robust(t1_fname, 
    remover = "double_remove_neck",
    outfile = outfile)
} else {
  ss = readnii(outfile)
}

## ----t1_ss_plot, cache = TRUE--------------------------------------------
ortho2(ss)

## ----t1_ss_plot2, cache = TRUE-------------------------------------------
alpha = function(col, alpha = 1) {
  cols = t(col2rgb(col, alpha = FALSE)/255)
  rgb(cols, alpha = alpha)
}      
ortho2(t1_fname, ss > 0, col.y = alpha("red", 0.5))

## ----t1_ss_red, cache = FALSE--------------------------------------------
ss_red = dropEmptyImageDimensions(ss)
ortho2(ss_red)

## ----spm12---------------------------------------------------------------
library(spm12r)

## ----spm12_segment, cache=FALSE, eval = TRUE-----------------------------
outfile = nii.stub(t1_fname, bn = TRUE)
spm_prob_files = paste0(outfile,
                        "_prob_", 1:6,
                        ".nii.gz")
ss_outfile = paste0(outfile, "_SPM_SS.nii.gz")
outfile = paste0(outfile, "_SPM_Seg.nii.gz")
outfiles = c(outfile, ss_outfile, spm_prob_files)
if (!all(file.exists(outfiles))) {
  spm_seg = spm12_segment(t1_fname)$outfiles
  spm_hard_seg = spm_probs_to_seg(img = spm_seg)
  writenii(spm_hard_seg, filename = outfile)
  
  spm_ss = spm_hard_seg >= 1 & spm_hard_seg <= 3
  writenii(spm_ss, filename = ss_outfile)
  
  for (i in seq_along(spm_seg)) {
    writenii(spm_seg[[i]], spm_prob_files[i]) 
  }  
} else {
  spm_seg = vector(mode = "list", 
                   length = length(spm_prob_files))
  for (i in seq_along(spm_seg)) {
    spm_seg[[i]] = readnii(spm_prob_files[i]) 
  }
  spm_hard_seg = readnii(outfile)
  spm_ss = readnii(ss_outfile)
}

## ----t1_spm_seg_plot, cache = TRUE---------------------------------------
double_ortho(t1_fname, spm_hard_seg)

## ----t1_spm_ss, cache = TRUE---------------------------------------------
alpha = function(col, alpha = 1) {
  cols = t(col2rgb(col, alpha = FALSE)/255)
  rgb(cols, alpha = alpha)
}      
ortho2(t1_fname, spm_ss > 0, col.y = alpha("red", 0.5))

## ----noneck, cache = FALSE-----------------------------------------------
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = paste0(outfile,
                 "_noneck.nii.gz")
if (!file.exists(outfile)) {
  noneck = extrantsr::double_remove_neck(
    t1_fname,
    template.file = file.path(fslr::fsldir(), "data/standard",
                              "MNI152_T1_1mm_brain.nii.gz"), 
    template.mask = file.path(fslr::fsldir(),
                              "data/standard", 
                              "MNI152_T1_1mm_brain_mask.nii.gz"))
  writenii(noneck, filename = outfile)
} else {
  noneck = readnii(outfile)
}

## ----noneck_plot, cache = TRUE-------------------------------------------
double_ortho(t1_fname, noneck)

## ----reduce_noneck, cache=FALSE------------------------------------------
noneck_red = dropEmptyImageDimensions(noneck)
ortho2(noneck_red)

## ----nn_spm12_segment, cache=FALSE, eval = TRUE--------------------------
library(spm12r)
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = paste0(outfile, "_noneck")
spm_prob_files = paste0(outfile,
                        "_prob_", 1:6,
                        ".nii.gz")
ss_outfile = paste0(outfile, "_SPM_SS.nii.gz")
outfile = paste0(outfile, "_SPM_Seg.nii.gz")
outfiles = c(outfile, ss_outfile, spm_prob_files)
if (!all(file.exists(outfiles))) {
  nn_spm_seg = spm12_segment(noneck_red)$outfiles
  nn_spm_hard_seg = spm_probs_to_seg(img = nn_spm_seg)
  writenii(nn_spm_hard_seg, filename = outfile)
  
  nn_spm_ss = nn_spm_hard_seg >= 1 & nn_spm_hard_seg <= 3
  writenii(nn_spm_ss, filename = ss_outfile)
  
  for (i in seq_along(nn_spm_seg)) {
    writenii(nn_spm_seg[[i]], spm_prob_files[i]) 
  }  
} else {
  nn_spm_seg = vector(mode = "list", 
                   length = length(spm_prob_files))
  for (i in seq_along(nn_spm_seg)) {
    nn_spm_seg[[i]] = readnii(spm_prob_files[i]) 
  }
  nn_spm_hard_seg = readnii(outfile)
  nn_spm_ss = readnii(ss_outfile)
}

## ----t1_nn_spm_seg_plot, cache = TRUE------------------------------------
double_ortho(noneck_red, nn_spm_hard_seg)

## ----t1_nn_spm_ss, cache = TRUE------------------------------------------
ortho2(noneck_red, nn_spm_ss > 0, col.y = alpha("red", 0.5))

## ----replace_empty_dims, cache=FALSE-------------------------------------
dd = dropEmptyImageDimensions(noneck, keep_ind = TRUE)
nn_spm_ss_full = replace_dropped_dimensions(img = nn_spm_ss,
                                            inds = dd$inds,
                                            orig.dim = dd$orig.dim)

## ----t1_nn_ss_plot_full, cache = TRUE------------------------------------
ortho2(t1_fname, nn_spm_ss_full, col.y = alpha("red", 0.5))

## ----spm_diff, cache=TRUE------------------------------------------------
ortho_diff(t1_fname, pred = nn_spm_ss_full, roi = spm_ss)

## ----spm_bet_diff, cache=TRUE--------------------------------------------
ortho_diff(t1_fname, pred = ss, roi = spm_ss)

