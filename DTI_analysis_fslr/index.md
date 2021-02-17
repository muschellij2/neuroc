---
title: "DTI Analysis in fslr"
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
---



All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/DTI_analysis_fslr/index.R).

# Resources and Goals
Much of this work has been adapted by the FSL guide for DTI: [http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide).  We will show you a few steps that have been implemented in `fslr`: `eddy_correct` and `dtifit`.  Although `xfibres` has been adapted for `fslr`, which is the backend for `bedpostx` from FSL, it takes a long time to run and the results are not seen in this vignette, though code is given to illustrate how it would be run.


# Data Packages

For this analysis, I will use one subject from the Kirby 21 data set.  The `kirby21.base` and `kirby21.dti` packages are necessary for this analysis and have the data we will be working on.  You need devtools to install these.  Please refer to [installing devtools](../installing_devtools/index.html) for additional instructions or troubleshooting.



```r
packages = installed.packages()
packages = packages[, "Package"]
if (!"kirby21.base" %in% packages) {
  source("https://neuroconductor.org/neurocLite.R")
  neuroc_install("kirby21.base")  
}
if (!"kirby21.dti" %in% packages) {
  source("https://neuroconductor.org/neurocLite.R")
  neuroc_install("kirby21.dti")  
}
```

# Loading Data

We will use the `get_image_filenames_df` function to extract the filenames on our hard disk for the T1 image.  


```r
library(kirby21.dti)
library(kirby21.base)
download_dti_data()
```

```
## [1] TRUE
```

```r
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
```



## Making b-vectors and b-values
As `dtifit` requires the b-values and b-vectors to be separated, we will take a look at this data.


```r
b_vals = readLines(b_fname)
b_vals = as.numeric(b_vals)
b0 = which(b_vals == 0)[1]

b_vecs = read.delim(grad_fname, header = FALSE)
stopifnot(all(is.na(b_vecs$V4)))
b_vecs$V4 = NULL
colnames(b_vecs) = c("x", "y", "z")
```

## Printing out FSL Version


```r
library(fslr)
print(fsl_version())
```

```
## [1] "6.0.4"
```

## Checking our data
Here we ensure that the number of b-values/b-vectors is the same as the number of time points in the 4D image.


```r
n_timepoints = fslval(dti_fname, "dim4")
```

```
## fslval "/Users/johnmuschelli/Library/R/4.0/library/kirby21.dti/visit_1/113/113-01-DTI.nii.gz" dim4
```

```r
stopifnot(nrow(b_vecs) == n_timepoints)
stopifnot(length(b_vals) == n_timepoints)
```


# Running `eddy_correct`
Here, we will run an eddy current correction using FSL's `eddy_correct` through `fslr`.  We will save the result in a temporary file (`outfile`), but also return the result as a `nifti` object `ret`, as `retimg = TRUE`.  We will use the first volume as the reference as is the default in FSL.  *Note* FSL is zero-indexed so the first volume is the zero-ith index:


```r
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
```

Let's look at the eddy current-corrected (left) and the non-corrected data (right).  Here we will look at the image where the b-value is equal to zero.  


```r
dti = readnii(dti_fname)
eddy0 = extrantsr::subset_4d(eddy, b0)
dti0 = extrantsr::subset_4d(dti, b0)
```


```r
double_ortho(robust_window(eddy0), robust_window(dti0))
```

![](index_files/figure-html/eddy0_plot-1.png)<!-- -->

Note, from here on forward we will use either the filename for the output of the eddy current correction or the eddy-current-corrected `nifti` object.

# Getting a brain mask

Let's get a brain mask from the eddy-corrected data:


```r
mask_fname = paste0(base_fname, "_mask.nii.gz")
if (!file.exists(mask_fname)) {
  fsl_bet(infile = dti0, outfile = mask_fname)
} 
mask = readnii(mask_fname)
```


```r
ortho2(robust_window(dti0), mask, col.y = alpha("red", 0.5))
```

![](index_files/figure-html/bet_plot-1.png)<!-- -->


# Running DTI Fitting as a cursor

Now that we have eddy current corrected our data, we can pass that result into `dtifit` to get FA maps and such:

```r
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
```

By default, the result of `dtifit` is the filenames of the resultant images.  Here we will read in those images:

```r
res_imgs = lapply(outfiles[c("FA", "MD")], readnii)
```

## Plotting an FA map
Using the `ortho2` function, you can plot the fractional anisotropy (FA) map

```r
ortho2(res_imgs$FA)
```

![](index_files/figure-html/plot_fa-1.png)<!-- -->

and the mean diffusivity (MD) map:

```r
ortho2(res_imgs$MD)
```

![](index_files/figure-html/plot_md-1.png)<!-- -->

or both at the same time using the `double_ortho` function:

```r
double_ortho(res_imgs$FA, res_imgs$MD)
```

![](index_files/figure-html/plot_fa_md-1.png)<!-- -->

You can look at a scatterplot of the FA vs MD values of all values inside the mask using the following code:

```r
mask = readnii(mask_fname)
df = data.frame(FA = res_imgs$FA[ mask == 1], 
                MD = res_imgs$MD[ mask == 1] )
ggplot(df, aes(x = FA, y = MD)) + stat_binhex()
```

![](index_files/figure-html/make_hex-1.png)<!-- -->

```r
rm(list = "df")
rm(list = "mask")
```

# Fitting bedpostx

Accoriding to [http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide), the `bedpostx` function from FSL stands for "Bayesian Estimation of Diffusion Parameters Obtained using Sampling Techniques. The X stands for modelling Crossing Fibres".  It also states "bedpostx takes about 15 hours to run".  We have implemented `xfibres`, the function `bedpostx` calls.  Running it with the default options, the command would be:


```r
xfibres(infile = outfile, 
        bvecs = b_vecs,
        bvals = b_vals,
        mask = mask_fname)
```
        
We are currently implementing `probtracx2` and an overall wrapper for all these functions to work as a pipeline.



# Session Info


```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.2 (2020-06-22)
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/New_York            
##  date     2021-02-16                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  ! package      * version   date       lib
##    abind          1.4-5     2016-07-21 [2]
##    animation    * 2.6       2018-12-11 [2]
##  R ANTsR        * 0.5.6.1   <NA>       [2]
##    ANTsRCore    * 0.7.4.9   2021-02-16 [1]
##    assertthat     0.2.1     2019-03-21 [2]
##    base64enc      0.1-3     2015-07-28 [2]
##    bitops         1.0-6     2013-08-17 [2]
##    cachem         1.0.4     2021-02-13 [1]
##    callr          3.5.1     2020-10-13 [1]
##    cli            2.3.0     2021-01-31 [1]
##    codetools      0.2-18    2020-11-04 [1]
##    colorout     * 1.2-2     2020-06-01 [2]
##    colorspace     2.0-0     2020-11-11 [1]
##    crayon         1.4.1     2021-02-08 [1]
##    DBI            1.1.1     2021-01-15 [1]
##    desc           1.2.0     2020-06-01 [2]
##    devtools     * 2.3.2     2020-09-18 [1]
##    digest         0.6.27    2020-10-24 [1]
##    dplyr        * 1.0.4     2021-02-02 [1]
##    ellipsis       0.3.1     2020-05-15 [2]
##    evaluate       0.14      2019-05-28 [2]
##    EveTemplate  * 1.0.0     2020-06-01 [2]
##    extrantsr    * 3.9.13.1  2020-09-03 [2]
##    farver         2.0.3     2020-01-16 [2]
##    fastmap        1.1.0     2021-01-25 [1]
##    fs             1.5.0     2020-07-31 [2]
##    fslr         * 2.25.0    2021-02-16 [1]
##    generics       0.1.0     2020-10-31 [1]
##    ggplot2      * 3.3.3     2020-12-30 [1]
##    git2r          0.28.0    2021-01-11 [1]
##    glue           1.4.2     2020-08-27 [1]
##    gtable         0.3.0     2019-03-25 [2]
##    highr          0.8       2019-03-20 [2]
##    htmltools      0.5.1.1   2021-01-22 [1]
##    httr           1.4.2     2020-07-20 [2]
##    ITKR           0.5.3.3.0 2021-02-15 [1]
##    kirby21.base * 1.7.4     2020-10-01 [1]
##    kirby21.dti  * 1.7.0     2020-10-01 [1]
##    kirby21.fmri * 1.7.0     2018-08-13 [2]
##    kirby21.t1   * 1.7.3.2   2021-01-09 [1]
##    knitr        * 1.31      2021-01-27 [1]
##    lattice        0.20-41   2020-04-02 [2]
##    lifecycle      1.0.0     2021-02-15 [1]
##    magrittr       2.0.1     2020-11-17 [1]
##    matlabr        1.6.0     2020-07-01 [2]
##    Matrix         1.3-2     2021-01-06 [1]
##    matrixStats  * 0.58.0    2021-01-29 [1]
##    memoise        2.0.0     2021-01-26 [1]
##    mgcv           1.8-33    2020-08-27 [1]
##    munsell        0.5.0     2018-06-12 [2]
##    neurobase    * 1.31.0    2020-10-07 [1]
##    neurohcp     * 0.9.0     2020-10-19 [1]
##    nlme           3.1-152   2021-02-04 [1]
##    oro.nifti    * 0.11.0    2020-09-04 [2]
##    pillar         1.4.7     2020-11-20 [1]
##    pkgbuild       1.2.0     2020-12-15 [1]
##    pkgconfig      2.0.3     2019-09-22 [2]
##    pkgload        1.1.0     2020-05-29 [2]
##    plyr         * 1.8.6     2020-03-03 [2]
##    prettyunits    1.1.1     2020-01-24 [2]
##    processx       3.4.5     2020-11-30 [1]
##    ps             1.5.0     2020-12-05 [1]
##    purrr          0.3.4     2020-04-17 [2]
##    R.matlab       3.6.2     2018-09-27 [2]
##    R.methodsS3  * 1.8.1     2020-08-26 [1]
##    R.oo         * 1.24.0    2020-08-26 [1]
##    R.utils      * 2.10.1    2020-08-26 [1]
##    R6             2.5.0     2020-10-28 [1]
##    RColorBrewer * 1.1-2     2014-12-07 [2]
##    Rcpp           1.0.6     2021-01-15 [1]
##    RcppEigen      0.3.3.9.1 2020-12-17 [1]
##    remotes        2.2.0     2020-07-21 [2]
##    reshape2     * 1.4.4     2020-04-09 [2]
##    rlang          0.4.10    2020-12-30 [1]
##    rmarkdown    * 2.6       2020-12-14 [1]
##    RNifti         1.3.0     2020-12-04 [1]
##    rprojroot      2.0.2     2020-11-15 [1]
##    rstudioapi     0.13      2020-11-12 [1]
##    scales         1.1.1     2020-05-11 [2]
##    sessioninfo    1.1.1     2018-11-05 [2]
##    spm12r       * 2.8.2     2021-01-11 [1]
##    stapler        0.7.2     2020-07-09 [2]
##    stringi        1.5.3     2020-09-09 [1]
##    stringr      * 1.4.0     2019-02-10 [2]
##    testthat       3.0.2     2021-02-14 [1]
##    tibble         3.0.6     2021-01-29 [1]
##    tidyselect     1.1.0     2020-05-11 [2]
##    usethis      * 2.0.1     2021-02-10 [1]
##    vctrs          0.3.6     2020-12-17 [1]
##    WhiteStripe    2.3.2     2019-10-01 [2]
##    withr          2.4.1     2021-01-26 [1]
##    xfun           0.21      2021-02-10 [1]
##    yaml         * 2.2.1     2020-02-01 [2]
##    zoo          * 1.8-8     2020-05-02 [2]
##  source                                  
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  <NA>                                    
##  Github (ANTsX/ANTsRCore@ddf445b)        
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  Github (jalvesaq/colorout@726d681)      
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  Github (muschellij2/desc@b0c374f)       
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  Github (muschellij2/EveTemplate@ed54115)
##  Github (muschellij2/extrantsr@00c75ad)  
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  local                                   
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  Github (ropensci/git2r@4e342ca)         
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  Github (stnava/ITKR@ea0ac19)            
##  local                                   
##  Github (muschellij2/kirby21.dti@1ad9d47)
##  CRAN (R 4.0.0)                          
##  local                                   
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  local                                   
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  local                                   
##  local                                   
##  CRAN (R 4.0.2)                          
##  local                                   
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
##  local                                   
##  Github (muschellij2/stapler@79e23d2)    
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.2)                          
##  CRAN (R 4.0.0)                          
##  CRAN (R 4.0.0)                          
## 
## [1] /Users/johnmuschelli/Library/R/4.0/library
## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
## 
##  R ── Package was removed from disk.
```

# References

