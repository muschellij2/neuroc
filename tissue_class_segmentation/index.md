---
title: "Tissue Class Segmentation"
author: "John Muschelli"
date: "2021-02-16"
output: 
  html_document:
    keep_md: true
    theme: cosmo
    toc: true
    toc_depth: 3
    toc_float:
      collapsed: false
    number_sections: true      
bibliography: ../refs.bib      
---

All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/tissue_class_segmentation/index.R).



In this tutorial we will discuss performing tissue class segmentation using `atropos` in `ANTsR` and it's wrapper function in `extrantsr`, `otropos`. 

# Data Packages

For this analysis, I will use one subject from the Kirby 21 data set.  The `kirby21.base` and `kirby21.fmri` packages are necessary for this analysis and have the data we will be working on.  You need devtools to install these.  Please refer to [installing devtools](../installing_devtools/index.html) for additional instructions or troubleshooting.



```r
packages = installed.packages()
packages = packages[, "Package"]
if (!"kirby21.base" %in% packages) {
  source("https://neuroconductor.org/neurocLite.R")
  neuroc_install("kirby21.base")    
}
if (!"kirby21.fmri" %in% packages) {
  source("https://neuroconductor.org/neurocLite.R")
  neuroc_install("kirby21.fmri")   
}
```

# Loading Data

We will use the `get_image_filenames_df` function to extract the filenames on our hard disk for the T1 image and the fMRI images (4D).  


```r
library(kirby21.t1)
library(kirby21.base)
fnames = get_image_filenames_df(ids = 113, 
                    modalities = c("T1"), 
                    visits = c(1),
                    long = FALSE)
t1_fname = fnames$T1[1]
```

# Using information from the T1 image

## Brain extracted image

Please visit the [brain extraction tutorial](../brain_extraction/index.html) on how to extract a brain from this image.  We will use the output from `fslbet_robust` from that tutorial.  


```r
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = file.path("..", "brain_extraction", outfile)
outfile = paste0(outfile, "_SS.nii.gz")
ss = readnii(outfile)
ss_red = dropEmptyImageDimensions(ss)
ortho2(ss_red)
```

![](index_files/figure-html/t1_ss-1.png)<!-- -->

Again, we can see the zoomed-in view of the image now.

## Tissue-Class Segmentation with Atropos


```r
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
```

### Atropos results 

Now we have a hard segmentation, which assigns a class with the maximum probability to that voxel.  We also have a separate probability image for each tissue class.


```r
double_ortho(ss_red, hard_seg)
```

![](index_files/figure-html/t1_seg_plot-1.png)<!-- -->

We see that much of the structures have been segmented well, but there may be errors.

### Atropos intensity histograms 

We can also look at the distribution of intensities (marginally) for each tissue class.  In `atropos`, the classes are ordered by mean intensity, so we can re-assign them to the corresponding tissue class

```r
df = data.frame(value = ss_red[ss_red > 0],
                class = hard_seg[ss_red > 0])
df$class = c("CSF", "GM", "WM")[df$class]
ggplot(df, aes(x = value, colour = factor(class))) + geom_line(stat = "density")
```

![](index_files/figure-html/t1_val_plot-1.png)<!-- -->

```r
rm(list = "df")
```


## Tissue-Class Segmentation with FAST


```r
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
```

### FAST results 
Let's see the results of the FAST segmentation:


```r
double_ortho(ss_red, hard_seg)
```

![](index_files/figure-html/fast_seg_plot-1.png)<!-- -->

### FAST intensity histograms 

Again, we can look at the distribution of values, ad now we can compare distributions of the values from FAST to that of atropos.


```r
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
```

```
Warning: Removed 596 rows containing non-finite values (stat_density).
```

![](index_files/figure-html/fast_val_plot-1.png)<!-- -->

```r
rm(list = "df")
```


## Tissue-Class Segmentation with SPM

In the [brain extraction tutorial](../brain_extraction/index.html) we discuss the SPM segmenation procedures and show how to use them to produce hard segmentations, probability maps, and a brain extracted image.  We will use the results of that tutorial to compare to that of `atropos`.  We will exclude any tissues outside of GM, WM, and CSF (those > 3).


```r
outfile = nii.stub(t1_fname, bn = TRUE)
outfile = file.path("..", "brain_extraction", outfile)
outfile = paste0(outfile, "_SPM_Seg.nii.gz")
spm_hard_seg = readnii(outfile)
spm_hard_seg[ spm_hard_seg > 3] = 0
dd = dropEmptyImageDimensions(
  ss,
  other.imgs = spm_hard_seg)
spm_hard_seg_red = dd$other.imgs
```


### SPM results


```r
double_ortho(ss_red, spm_hard_seg_red)
```

![](index_files/figure-html/t1_spm_seg_plot-1.png)<!-- -->

Remember however, in the SPM segmentation, 1 is GM, 2 is WM, 3 is CSF, and in Atropos/FAST, 1 is CSF, 2 is GM, 3 is WM, .


```r
spm_recode = niftiarr(spm_hard_seg_red, 0)
spm_recode[ spm_hard_seg_red %in% 1 ] = 2
spm_recode[ spm_hard_seg_red %in% 2 ] = 3
spm_recode[ spm_hard_seg_red %in% 3 ] = 1
```


```r
double_ortho(ss_red, spm_recode)
```

![](index_files/figure-html/t1_spm_recode_seg_plot-1.png)<!-- -->


```r
df = data.frame(spm = spm_recode[spm_recode > 0 | hard_seg > 0],
                atropos = hard_seg[spm_recode > 0 | hard_seg > 0],
                value = ss_red[spm_recode > 0 | hard_seg > 0])
df$spm = c("Background", "CSF", "GM", "WM")[df$spm + 1]
df$atropos = c("Background", "CSF", "GM", "WM")[df$atropos + 1]
df$spm = factor(df$spm, levels = c("Background", "CSF", "GM", "WM"))
df$atropos = factor(df$atropos, levels = c("Background", "CSF", "GM", "WM"))
tab = with(df, table(spm, atropos))
print(tab)
```

```
            atropos
spm          Background    CSF     GM     WM
  Background          0  27972   1053    756
  CSF             50255 102999   7146      0
  GM              23839  66622 450565  60141
  WM                455      0    946 339557
```

We can also compare the 2 segmentations.  Here, if we assume the SPM segmentation as the "gold standard" and the Atropos one as another "prediction", we can look at the differences.  Anywhere they both agree (both are a 1) it will be deemed a true positive and will be in green.  Anywhere the Atropos segmentation includes a voxel but the SPM segmentation did not, it will deemed a false positive and will be in blue, vice versa in red will be a false negative.


```r
compare = spm_recode == hard_seg
compare[ (spm_recode > 0 | hard_seg > 0) & !compare ] = 2
compare[ spm_recode == 0 & hard_seg == 0  ] = 0
```


```r
ortho2(ss_red, compare, col.y = alpha(c("blue", "red"), 0.5))
```

![](index_files/figure-html/t1_compare_seg_plot-1.png)<!-- -->

```r
double_ortho(ss_red, compare, col.y = alpha(c("blue", "red"), 0.5))
```

![](index_files/figure-html/t1_compare_seg_plot-2.png)<!-- -->


```r
x = list(ss_red,
             ss_red)
y = list(spm = spm_recode,
         atropos = hard_seg)
z = floor(nsli(ss_red)/2)
multi_overlay(x, y, z = z, col.y = alpha(hotmetal(), 0.25))
```

![](index_files/figure-html/compare_multi-1.png)<!-- -->

### SPM intensity histograms 

Although there may be places in the brain where SPM calls a class CSF, WM, or GM where the brain mask is zero, we will exclude these in the comparison to fast and atropos for a common comparison.  We will make sure that if voxels within the brain mask are labeled as zero in the SPM segmentation, we will denote these as `Background`.


```r
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
```

```
Warning: Removed 894 rows containing non-finite values (stat_density).
```

![](index_files/figure-html/spm_val_plot-1.png)<!-- -->

```r
rm(list = "df")
```

## Discussion

Note, `atropos` and `fast` generally require a skull-stripped image.  Many skull-stripping algorithms remove the extra-cortical areas of the brain but inside the skull, which generally are CSF spaces with meninges.  These CSF spaces are dropped after skull-stripping/brain extraction.  If we are trying to consistently measure the CSF or "whole brain volume" (if that includes CSF spaces), this may cause issues.  The SPM segmentation usually includes more CSF spaces, but we have shown in the [brain extraction tutorial](../brain_extraction/index.html) that there are areas that BET denotes as brain and SPM does not on the surface.   


# Session Info


```r
devtools::session_info()
```

```
─ Session info ───────────────────────────────────────────────────────────────
 setting  value                       
 version  R version 4.0.2 (2020-06-22)
 os       macOS Catalina 10.15.7      
 system   x86_64, darwin17.0          
 ui       X11                         
 language (EN)                        
 collate  en_US.UTF-8                 
 ctype    en_US.UTF-8                 
 tz       America/New_York            
 date     2021-02-16                  

─ Packages ───────────────────────────────────────────────────────────────────
 package        * version   date       lib
 abind            1.4-5     2016-07-21 [2]
 animation      * 2.6       2018-12-11 [2]
 ANTsR          * 0.5.6.1   2020-06-01 [2]
 ANTsRCore      * 0.7.4.6   2020-07-07 [2]
 assertthat       0.2.1     2019-03-21 [2]
 base64enc        0.1-3     2015-07-28 [2]
 bindr            0.1.1     2018-03-13 [2]
 bindrcpp       * 0.2.2     2018-03-29 [2]
 bitops           1.0-6     2013-08-17 [2]
 cachem           1.0.4     2021-02-13 [1]
 callr            3.5.1     2020-10-13 [1]
 cli              2.3.0     2021-01-31 [1]
 codetools        0.2-18    2020-11-04 [1]
 colorout       * 1.2-2     2020-06-01 [2]
 colorspace       2.0-0     2020-11-11 [1]
 crayon           1.4.1     2021-02-08 [1]
 DBI              1.1.1     2021-01-15 [1]
 dcm2niir       * 0.6.9.1   2020-06-01 [2]
 desc             1.2.0     2020-06-01 [2]
 devtools         2.3.2     2020-09-18 [1]
 digest           0.6.27    2020-10-24 [1]
 dplyr          * 1.0.4     2021-02-02 [1]
 ellipsis         0.3.1     2020-05-15 [2]
 evaluate         0.14      2019-05-28 [2]
 EveTemplate    * 1.0.0     2020-06-01 [2]
 extrantsr      * 3.9.13.1  2020-09-03 [2]
 farver           2.0.3     2020-01-16 [2]
 fastmap          1.1.0     2021-01-25 [1]
 fs               1.5.0     2020-07-31 [2]
 fslr           * 2.25.0    2021-02-16 [1]
 generics         0.1.0     2020-10-31 [1]
 ggplot2        * 3.3.3     2020-12-30 [1]
 git2r          * 0.28.0    2021-01-11 [1]
 glue             1.4.2     2020-08-27 [1]
 gtable           0.3.0     2019-03-25 [2]
 hexbin         * 1.28.2    2021-01-08 [1]
 highr            0.8       2019-03-20 [2]
 htmltools        0.5.1.1   2021-01-22 [1]
 htmlwidgets      1.5.3     2020-12-10 [1]
 httr             1.4.2     2020-07-20 [2]
 ichseg         * 0.17.5    2020-08-13 [2]
 ITKR             0.5.3.3.0 2021-02-15 [1]
 jsonlite         1.7.2     2020-12-09 [1]
 kirby21.base   * 1.7.4     2020-10-01 [1]
 kirby21.fmri   * 1.7.0     2018-08-13 [2]
 kirby21.t1     * 1.7.3.2   2021-01-09 [1]
 knitr            1.31      2021-01-27 [1]
 labeling         0.4.2     2020-10-20 [1]
 lattice          0.20-41   2020-04-02 [2]
 lifecycle        1.0.0     2021-02-15 [1]
 magic            1.5-9     2018-09-17 [2]
 magrittr         2.0.1     2020-11-17 [1]
 matlabr        * 1.6.0     2020-07-01 [2]
 Matrix           1.3-2     2021-01-06 [1]
 matrixStats    * 0.58.0    2021-01-29 [1]
 memoise          2.0.0     2021-01-26 [1]
 mgcv             1.8-33    2020-08-27 [1]
 mmand            1.6.1     2020-03-03 [2]
 MNITemplate    * 1.0.0     2020-06-01 [2]
 munsell          0.5.0     2018-06-12 [2]
 neurobase      * 1.31.0    2020-10-07 [1]
 neurohcp       * 0.9.0     2020-10-19 [1]
 nlme             3.1-152   2021-02-04 [1]
 oasis          * 3.0.4     2018-02-21 [2]
 oro.nifti      * 0.11.0    2020-09-04 [2]
 papayaWidget   * 0.7.1     2020-09-14 [1]
 pillar           1.4.7     2020-11-20 [1]
 pkgbuild         1.2.0     2020-12-15 [1]
 pkgconfig        2.0.3     2019-09-22 [2]
 pkgload          1.1.0     2020-05-29 [2]
 plyr             1.8.6     2020-03-03 [2]
 prettyunits      1.1.1     2020-01-24 [2]
 processx         3.4.5     2020-11-30 [1]
 ps               1.5.0     2020-12-05 [1]
 purrr            0.3.4     2020-04-17 [2]
 R.matlab         3.6.2     2018-09-27 [2]
 R.methodsS3    * 1.8.1     2020-08-26 [1]
 R.oo           * 1.24.0    2020-08-26 [1]
 R.utils        * 2.10.1    2020-08-26 [1]
 R6               2.5.0     2020-10-28 [1]
 randomForest     4.6-14    2018-03-25 [2]
 RColorBrewer   * 1.1-2     2014-12-07 [2]
 Rcpp             1.0.6     2021-01-15 [1]
 RcppEigen        0.3.3.9.1 2020-12-17 [1]
 remotes          2.2.0     2020-07-21 [2]
 reshape2       * 1.4.4     2020-04-09 [2]
 rlang            0.4.10    2020-12-30 [1]
 rmarkdown      * 2.6       2020-12-14 [1]
 RNifti         * 1.3.0     2020-12-04 [1]
 rprojroot        2.0.2     2020-11-15 [1]
 rstudioapi       0.13      2020-11-12 [1]
 rvest          * 0.3.6     2020-07-25 [2]
 scales         * 1.1.1     2020-05-11 [2]
 sessioninfo      1.1.1     2018-11-05 [2]
 spm12r         * 2.8.2     2021-01-11 [1]
 stapler          0.7.2     2020-07-09 [2]
 stringi          1.5.3     2020-09-09 [1]
 stringr        * 1.4.0     2019-02-10 [2]
 TCIApathfinder * 1.0.7     2021-02-04 [1]
 testthat         3.0.2     2021-02-14 [1]
 tibble           3.0.6     2021-01-29 [1]
 tidyselect       1.1.0     2020-05-11 [2]
 usethis          2.0.1     2021-02-10 [1]
 vctrs            0.3.6     2020-12-17 [1]
 WhiteStripe      2.3.2     2019-10-01 [2]
 withr            2.4.1     2021-01-26 [1]
 xfun             0.21      2021-02-10 [1]
 xml2           * 1.3.2     2020-04-23 [2]
 yaml           * 2.2.1     2020-02-01 [2]
 zoo            * 1.8-8     2020-05-02 [2]
 source                                  
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 Github (ANTsX/ANTsR@9c7c9b7)            
 Github (muschellij2/ANTsRCore@61c37a1)  
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 Github (jalvesaq/colorout@726d681)      
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 Github (muschellij2/dcm2niir@4515762)   
 Github (muschellij2/desc@b0c374f)       
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 Github (muschellij2/EveTemplate@ed54115)
 Github (muschellij2/extrantsr@00c75ad)  
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 local                                   
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 Github (ropensci/git2r@4e342ca)         
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 Github (muschellij2/ichseg@2741696)     
 Github (stnava/ITKR@ea0ac19)            
 CRAN (R 4.0.2)                          
 local                                   
 CRAN (R 4.0.0)                          
 local                                   
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 local                                   
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 Github (muschellij2/MNITemplate@46e8f81)
 CRAN (R 4.0.0)                          
 local                                   
 local                                   
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 local                                   
 local                                   
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 local                                   
 Github (muschellij2/stapler@79e23d2)    
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 local                                   
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.2)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          
 CRAN (R 4.0.0)                          

[1] /Users/johnmuschelli/Library/R/4.0/library
[2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```

# References
