## ----setup, include=FALSE------------------------------------------------
library(kirby21.fmri)
library(kirby21.base)
library(dplyr)
library(neurobase)
library(ANTsR)
library(R.utils)
library(RColorBrewer)
library(matrixStats)
library(ggplot2)
library(reshape2)
library(animation)
library(zoo)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")

## ---- eval = FALSE-------------------------------------------------------
## packages = installed.packages()
## packages = packages[, "Package"]
## if (!"kirby21.base" %in% packages) {
##   source("https://neuroconductor.org/neurocLite.R")
##   neuroc_install("kirby21.base")
## }
## if (!"kirby21.fmri" %in% packages) {
##   source("https://neuroconductor.org/neurocLite.R")
##   neuroc_install("kirby21.fmri")
## }

## ----data----------------------------------------------------------------
library(kirby21.t1)
library(kirby21.base)
fnames = get_image_filenames_df(ids = 113, 
                    modalities = c("T1"), 
                    visits = c(1),
                    long = FALSE)
t1_fname = fnames$T1[1]

## ----t1_ss, cache = FALSE------------------------------------------------
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = file.path("..", "brain_extraction", outfile)
outfile = paste0(outfile, "_SS.nii.gz")
ss = readnii(outfile)
ss_red = dropEmptyImageDimensions(ss)
ortho2(ss_red)

## ----t1_seg, cache = FALSE-----------------------------------------------
outfile = nii.stub(t1_fname, bn = TRUE)
prob_files = paste0(outfile,
                    "_prob_", 1:3,
                    ".nii.gz")
seg_outfile = paste0(outfile, "_Seg.nii.gz")

if (!all(file.exists(
  c(seg_outfile, prob_files)
  ))) {
  seg = extrantsr::otropos(
    ss_red, 
    x = ss_red > 0,
    v = 1)
  hard_seg = seg$segmentation
  writenii(hard_seg, seg_outfile)
  for (i in seq_along(seg$probabilityimages)) {
    writenii(seg$probabilityimages[[i]], prob_files[i]) 
  }
  # writenii(seg, )
} else {
  hard_seg = readnii(seg_outfile)
  seg = vector(mode = "list", length = 2)
  names(seg) = c("segmentation", "probabilityimages")
  seg$segmentation = hard_seg
  seg$probabilityimages = vector(mode = "list", length = 3)
  for (i in 1:3) {
    seg$probabilityimages[[i]] = readnii(prob_files[i]) 
  }  
}

## ----t1_seg_plot, cache = TRUE-------------------------------------------
double_ortho(ss_red, hard_seg)

## ----t1_val_plot, cache = TRUE-------------------------------------------
df = data.frame(value = ss_red[ss_red > 0],
                class = hard_seg[ss_red > 0])
df$class = c("CSF", "GM", "WM")[df$class]
ggplot(df, aes(x = value, colour = factor(class))) + geom_line(stat = "density")
rm(list = "df")

## ----t1_fast_seg, cache = FALSE------------------------------------------
library(fslr)
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = paste0(outfile, "_FAST")
prob_files = paste0(outfile,
                    "_pve_", 0:2,
                    ".nii.gz")
seg_outfile = paste0(outfile, "_Seg.nii.gz")

if (!all(file.exists(
  c(seg_outfile, prob_files)
  ))) {
  fast_hard_seg = fast(file = ss_red, 
                   outfile = outfile, 
                   out_type = "seg",
                   opts = "--nobias")
  writenii(fast_hard_seg, seg_outfile)
} else {
  fast_hard_seg = readnii(seg_outfile)
}
fast_seg = vector(mode = "list", length = 3)
for (i in 1:3) {
  fast_seg[[i]] = readnii(prob_files[i]) 
}  

## ----fast_seg_plot, cache = TRUE-----------------------------------------
double_ortho(ss_red, hard_seg)

## ----fast_val_plot, cache = TRUE-----------------------------------------
df = data.frame(value = ss_red[ss_red > 0],
                fast = fast_hard_seg[ss_red > 0],
                atropos = hard_seg[ss_red > 0],
                ind = which(ss_red > 0)
                )
df = reshape2::melt(df, id.vars = c("ind", "value"), 
                    measure.vars = c("fast", "atropos"),
                    value.name = "class",
                    variable.name = "segmentation")
df = df %>% arrange(ind)
df$ind = NULL

df$class = c("CSF", "GM", "WM")[df$class]
ggplot(df, aes(x = value, colour = factor(class))) + 
  geom_line(stat = "density") + 
  xlim(c(0, 1e6)) +
  facet_wrap(~ segmentation, ncol = 1)
rm(list = "df")

## ----spm_seg, cache = FALSE----------------------------------------------
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = file.path("..", "brain_extraction", outfile)
outfile = paste0(outfile, "_SPM_Seg.nii.gz")
spm_hard_seg = readnii(outfile)
spm_hard_seg[ spm_hard_seg > 3] = 0
dd = dropEmptyImageDimensions(
  ss,
  other.imgs = spm_hard_seg)
spm_hard_seg_red = dd$other.imgs

## ----t1_spm_seg_plot, cache = TRUE---------------------------------------
double_ortho(ss_red, spm_hard_seg_red)

## ----recode_spm, cache= FALSE--------------------------------------------
spm_recode = niftiarr(spm_hard_seg_red, 0)
spm_recode[ spm_hard_seg_red %in% 1 ] = 2
spm_recode[ spm_hard_seg_red %in% 2 ] = 3
spm_recode[ spm_hard_seg_red %in% 3 ] = 1

## ----t1_spm_recode_seg_plot, cache = TRUE--------------------------------
double_ortho(ss_red, spm_recode)

## ----seg_compare, cache = FALSE------------------------------------------
df = data.frame(spm = spm_recode[spm_recode > 0 | hard_seg > 0],
                atropos = hard_seg[spm_recode > 0 | hard_seg > 0],
                value = ss_red[spm_recode > 0 | hard_seg > 0])
df$spm = c("Background", "CSF", "GM", "WM")[df$spm + 1]
df$atropos = c("Background", "CSF", "GM", "WM")[df$atropos + 1]
df$spm = factor(df$spm, levels = c("Background", "CSF", "GM", "WM"))
df$atropos = factor(df$atropos, levels = c("Background", "CSF", "GM", "WM"))
tab = with(df, table(spm, atropos))
print(tab)

## ----compare_seg, cache = FALSE------------------------------------------
compare = spm_recode == hard_seg
compare[ (spm_recode > 0 | hard_seg > 0) & !compare ] = 2
compare[ spm_recode == 0 & hard_seg == 0  ] = 0


## ----t1_compare_seg_plot, cache = TRUE-----------------------------------
ortho2(ss_red, compare, col.y = alpha(c("blue", "red"), 0.5))
double_ortho(ss_red, compare, col.y = alpha(c("blue", "red"), 0.5))

## ----compare_multi, cache = TRUE-----------------------------------------
x = list(ss_red,
             ss_red)
y = list(spm = spm_recode,
         atropos = hard_seg)
z = floor(nsli(ss_red)/2)
multi_overlay(x, y, z = z, col.y = alpha(hotmetal(), 0.25))

## ----spm_val_plot, cache = TRUE------------------------------------------
df = data.frame(value = ss_red[ss_red > 0],
                fast = fast_hard_seg[ss_red > 0],
                atropos = hard_seg[ss_red > 0],
                spm = spm_recode[ss_red > 0],
                ind = which(ss_red > 0)
                )
df = reshape2::melt(df, id.vars = c("ind", "value"), 
                    measure.vars = c("fast", "atropos", "spm"),
                    value.name = "class",
                    variable.name = "segmentation")
df = df %>% arrange(ind)
df$ind = NULL

df$class = c("Background", "CSF", "GM", "WM")[df$class + 1]
ggplot(df, aes(x = value, colour = factor(class))) + 
  geom_line(stat = "density") + 
  xlim(c(0, 1e6)) +
  facet_wrap(~ segmentation, ncol = 1)
rm(list = "df")

## ---- cache = FALSE------------------------------------------------------
devtools::session_info()

