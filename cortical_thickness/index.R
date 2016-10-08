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

## ----kk, cache=FALSE-----------------------------------------------------
s = antsImageRead(seg)
g = antsImageRead(gm_prob)
w = antsImageRead(wm_prob)
out = kellyKapowski(s = s, g = g, w = w, its = 50, r = 0.025, m = 1.5)
cort = extrantsr::ants2oro(out)
ss = readnii(orig)
img = dropEmptyImageDimensions(ss)

## ----plot_cort-----------------------------------------------------------
ortho2(cort)

## ----hist_cort-----------------------------------------------------------
hist(c(cort[cort > 0]), breaks = 2000)

## ----thresh_cort---------------------------------------------------------
ortho2(cort, cort > 1)

## ----overlay_cort--------------------------------------------------------
ortho2(img, cort)

