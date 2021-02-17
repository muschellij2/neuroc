---
title: "Cortical Thickness Estimation"
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

All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/cortical_thickness/index.R).





```r
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
```



```r
s = antsImageRead(seg)
g = antsImageRead(gm_prob)
w = antsImageRead(wm_prob)
out = kellyKapowski(s = s, g = g, w = w, its = 50, r = 0.025, m = 1.5)
cort = extrantsr::ants2oro(out)
```





```r
ortho2(cort)
```

![](index_files/figure-html/plot_cort-1.png)<!-- -->


```r
hist(c(cort[cort > 0]), breaks = 2000)
```

![](index_files/figure-html/hist_cort-1.png)<!-- -->


```r
ortho2(cort, cort > 0.1)
```

![](index_files/figure-html/thresh_cort-1.png)<!-- -->


```r
ortho2(img, cort)
```

![](index_files/figure-html/overlay_cort-1.png)<!-- -->


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
 package      * version   date       lib source                                
 abind          1.4-5     2016-07-21 [2] CRAN (R 4.0.0)                        
 animation    * 2.6       2018-12-11 [2] CRAN (R 4.0.0)                        
 ANTsR        * 0.5.6.1   2020-06-01 [2] Github (ANTsX/ANTsR@9c7c9b7)          
 ANTsRCore    * 0.7.4.6   2020-07-07 [2] Github (muschellij2/ANTsRCore@61c37a1)
 assertthat     0.2.1     2019-03-21 [2] CRAN (R 4.0.0)                        
 bitops         1.0-6     2013-08-17 [2] CRAN (R 4.0.0)                        
 cachem         1.0.4     2021-02-13 [1] CRAN (R 4.0.2)                        
 callr          3.5.1     2020-10-13 [1] CRAN (R 4.0.2)                        
 cli            2.3.0     2021-01-31 [1] CRAN (R 4.0.2)                        
 codetools      0.2-18    2020-11-04 [1] CRAN (R 4.0.2)                        
 colorout     * 1.2-2     2020-06-01 [2] Github (jalvesaq/colorout@726d681)    
 colorspace     2.0-0     2020-11-11 [1] CRAN (R 4.0.2)                        
 crayon         1.4.1     2021-02-08 [1] CRAN (R 4.0.2)                        
 DBI            1.1.1     2021-01-15 [1] CRAN (R 4.0.2)                        
 desc           1.2.0     2020-06-01 [2] Github (muschellij2/desc@b0c374f)     
 devtools     * 2.3.2     2020-09-18 [1] CRAN (R 4.0.2)                        
 digest         0.6.27    2020-10-24 [1] CRAN (R 4.0.2)                        
 dplyr        * 1.0.4     2021-02-02 [1] CRAN (R 4.0.2)                        
 ellipsis       0.3.1     2020-05-15 [2] CRAN (R 4.0.0)                        
 evaluate       0.14      2019-05-28 [2] CRAN (R 4.0.0)                        
 extrantsr    * 3.9.13.1  2020-09-03 [2] Github (muschellij2/extrantsr@00c75ad)
 fastmap        1.1.0     2021-01-25 [1] CRAN (R 4.0.2)                        
 fs             1.5.0     2020-07-31 [2] CRAN (R 4.0.2)                        
 fslr         * 2.25.0    2021-02-16 [1] local                                 
 generics       0.1.0     2020-10-31 [1] CRAN (R 4.0.2)                        
 ggplot2      * 3.3.3     2020-12-30 [1] CRAN (R 4.0.2)                        
 git2r          0.28.0    2021-01-11 [1] Github (ropensci/git2r@4e342ca)       
 glue           1.4.2     2020-08-27 [1] CRAN (R 4.0.2)                        
 gtable         0.3.0     2019-03-25 [2] CRAN (R 4.0.0)                        
 highr          0.8       2019-03-20 [2] CRAN (R 4.0.0)                        
 htmltools      0.5.1.1   2021-01-22 [1] CRAN (R 4.0.2)                        
 ITKR           0.5.3.3.0 2021-02-15 [1] Github (stnava/ITKR@ea0ac19)          
 kirby21.base * 1.7.4     2020-10-01 [1] local                                 
 kirby21.fmri * 1.7.0     2018-08-13 [2] CRAN (R 4.0.0)                        
 kirby21.t1   * 1.7.3.2   2021-01-09 [1] local                                 
 knitr          1.31      2021-01-27 [1] CRAN (R 4.0.2)                        
 lattice        0.20-41   2020-04-02 [2] CRAN (R 4.0.2)                        
 lifecycle      1.0.0     2021-02-15 [1] CRAN (R 4.0.2)                        
 magrittr       2.0.1     2020-11-17 [1] CRAN (R 4.0.2)                        
 matlabr        1.6.0     2020-07-01 [2] local                                 
 Matrix         1.3-2     2021-01-06 [1] CRAN (R 4.0.2)                        
 matrixStats  * 0.58.0    2021-01-29 [1] CRAN (R 4.0.2)                        
 memoise        2.0.0     2021-01-26 [1] CRAN (R 4.0.2)                        
 mgcv           1.8-33    2020-08-27 [1] CRAN (R 4.0.2)                        
 munsell        0.5.0     2018-06-12 [2] CRAN (R 4.0.0)                        
 neurobase    * 1.31.0    2020-10-07 [1] local                                 
 nlme           3.1-152   2021-02-04 [1] CRAN (R 4.0.2)                        
 oro.nifti    * 0.11.0    2020-09-04 [2] local                                 
 pillar         1.4.7     2020-11-20 [1] CRAN (R 4.0.2)                        
 pkgbuild       1.2.0     2020-12-15 [1] CRAN (R 4.0.2)                        
 pkgconfig      2.0.3     2019-09-22 [2] CRAN (R 4.0.0)                        
 pkgload        1.1.0     2020-05-29 [2] CRAN (R 4.0.0)                        
 plyr           1.8.6     2020-03-03 [2] CRAN (R 4.0.0)                        
 prettyunits    1.1.1     2020-01-24 [2] CRAN (R 4.0.0)                        
 processx       3.4.5     2020-11-30 [1] CRAN (R 4.0.2)                        
 ps             1.5.0     2020-12-05 [1] CRAN (R 4.0.2)                        
 purrr          0.3.4     2020-04-17 [2] CRAN (R 4.0.0)                        
 R.matlab       3.6.2     2018-09-27 [2] CRAN (R 4.0.0)                        
 R.methodsS3  * 1.8.1     2020-08-26 [1] CRAN (R 4.0.2)                        
 R.oo         * 1.24.0    2020-08-26 [1] CRAN (R 4.0.2)                        
 R.utils      * 2.10.1    2020-08-26 [1] CRAN (R 4.0.2)                        
 R6             2.5.0     2020-10-28 [1] CRAN (R 4.0.2)                        
 RColorBrewer * 1.1-2     2014-12-07 [2] CRAN (R 4.0.0)                        
 Rcpp           1.0.6     2021-01-15 [1] CRAN (R 4.0.2)                        
 RcppEigen      0.3.3.9.1 2020-12-17 [1] CRAN (R 4.0.2)                        
 remotes        2.2.0     2020-07-21 [2] CRAN (R 4.0.2)                        
 reshape2     * 1.4.4     2020-04-09 [2] CRAN (R 4.0.0)                        
 rlang          0.4.10    2020-12-30 [1] CRAN (R 4.0.2)                        
 rmarkdown    * 2.6       2020-12-14 [1] CRAN (R 4.0.2)                        
 RNifti       * 1.3.0     2020-12-04 [1] CRAN (R 4.0.2)                        
 rprojroot      2.0.2     2020-11-15 [1] CRAN (R 4.0.2)                        
 rstudioapi     0.13      2020-11-12 [1] CRAN (R 4.0.2)                        
 scales         1.1.1     2020-05-11 [2] CRAN (R 4.0.0)                        
 sessioninfo    1.1.1     2018-11-05 [2] CRAN (R 4.0.0)                        
 spm12r       * 2.8.2     2021-01-11 [1] local                                 
 stapler        0.7.2     2020-07-09 [2] Github (muschellij2/stapler@79e23d2)  
 stringi        1.5.3     2020-09-09 [1] CRAN (R 4.0.2)                        
 stringr      * 1.4.0     2019-02-10 [2] CRAN (R 4.0.0)                        
 testthat       3.0.2     2021-02-14 [1] CRAN (R 4.0.2)                        
 tibble         3.0.6     2021-01-29 [1] CRAN (R 4.0.2)                        
 tidyselect     1.1.0     2020-05-11 [2] CRAN (R 4.0.0)                        
 usethis      * 2.0.1     2021-02-10 [1] CRAN (R 4.0.2)                        
 vctrs          0.3.6     2020-12-17 [1] CRAN (R 4.0.2)                        
 WhiteStripe    2.3.2     2019-10-01 [2] CRAN (R 4.0.0)                        
 withr          2.4.1     2021-01-26 [1] CRAN (R 4.0.2)                        
 xfun           0.21      2021-02-10 [1] CRAN (R 4.0.2)                        
 yaml         * 2.2.1     2020-02-01 [2] CRAN (R 4.0.0)                        
 zoo          * 1.8-8     2020-05-02 [2] CRAN (R 4.0.0)                        

[1] /Users/johnmuschelli/Library/R/4.0/library
[2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```

# References
