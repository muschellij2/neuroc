## ----setup, include=FALSE------------------------------------------------
library(ANTsR)
library(extrantsr)
library(kirby21.t1)
library(neurobase)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")

## ----files---------------------------------------------------------------
base_fname = "113-01-T1"
orig = file.path("..", 
                 "brain_extraction",
                 paste0(base_fname, "_SS.nii.gz")
)
stub = file.path("..", "tissue_class_segmentation", 
                base_fname)
seg = paste0(stub, "_Seg.nii.gz")
wm_prob = paste0(stub, "_prob_2.nii.gz")
gm_prob = paste0(stub, "_prob_3.nii.gz")

## ----kk_show, eval = FALSE, echo = TRUE----------------------------------
## s = antsImageRead(seg)
## g = antsImageRead(gm_prob)
## w = antsImageRead(wm_prob)
## out = kellyKapowski(s = s, g = g, w = w, its = 50, r = 0.025, m = 1.5)
## cort = extrantsr::ants2oro(out)

## ----kk_run, cache = TRUE, eval = TRUE, echo = FALSE---------------------
outfile = paste0(base_fname, "_cort_thick.nii.gz")
if (!file.exists(outfile)) {
  s = antsImageRead(seg)
  g = antsImageRead(gm_prob)
  w = antsImageRead(wm_prob)
  out = kellyKapowski(s = s, g = g, w = w, its = 50, r = 0.025, m = 1.5)
  cort = extrantsr::ants2oro(out)
  writenii(cort, filename = outfile)
} 

## ----cort_read, echo = FALSE, eval = TRUE, cache = FALSE-----------------
cort = readnii(outfile)
ss = readnii(orig)
dd = dropEmptyImageDimensions(ss, keep_ind = TRUE)
img = apply_empty_dim(img = ss, inds = dd$inds)

## ----plot_cort-----------------------------------------------------------
ortho2(cort)

## ----hist_cort-----------------------------------------------------------
hist(c(cort[cort > 0]), breaks = 2000)

## ----thresh_cort---------------------------------------------------------
ortho2(cort, cort > 0.1)

## ----overlay_cort--------------------------------------------------------
ortho2(img, cort)

## ---- cache = FALSE------------------------------------------------------
devtools::session_info()

