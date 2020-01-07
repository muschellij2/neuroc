---
title: "Getting Data from the Human Connectome Project (HCP)"
author: "John Muschelli"
date: "2019-01-11"
output:
  html_document:
    keep_md: yes
    number_sections: yes
    theme: cosmo
    toc: yes
    toc_depth: 3
    toc_float:
      collapsed: no
bibliography: ../refs.bib
---

All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/neurohcp/index.R).



# Human Connectome Project (HCP)
The [Human Connectome Project](https://www.humanconnectome.org/) (HCP) is a consortium of sites whose goal is to map "human brain circuitry in a target number of 1200 healthy adults using cutting-edge methods of noninvasive neuroimaging" ([https://www.humanconnectome.org/](https://www.humanconnectome.org/)).  It includes a large cohort of individuals with a vast amount of neuroimaging data ranging from structural magnetic resonance imaging (MRI), functional MRI -- both during tasks and resting-state-- and diffusion tensor imaging (DTI), from multiple sites. 

# Getting Access to the Data

The data is available to those that agree to the license.  Users can either pay to get hard drives of the data sent to them, named "Connectome In A Box", or access the data online.  The data can be obtained through the database at [http://db.humanconnectome.org](http://db.humanconnectome.org).  Data can be downloaded from the website directly in a browser or through an Amazon Simple Storage Solution (S3) bucket.  We will focus on accessing the data from S3.
 
## Getting an Access/API Key

Once logged into [http://db.humanconnectome.org](http://db.humanconnectome.org) and the terms are accepted, the user must enable Amazon S3 access for their Amazon account.  The user will then be provided an access key identifier (ID), which is required to authenticate a user to Amazon as well as a secret key.  These access and secret keys are necessary for the [neurohcp package](https://github.com/muschellij2/neurohcp), and will be referred to as access keys or API (application program interface) keys.

# Installing the `neurohcp` package

We will install the `neurohcp` package using the Neuroconductor installer:

```r
source("http://neuroconductor.org/neurocLite.R")
neuro_install("Rxnat", release = "stable")
```



# Session Info


```r
devtools::session_info()
```

```
─ Session info ──────────────────────────────────────────────────────────
 setting  value                       
 version  R version 3.5.0 (2018-04-23)
 os       macOS  10.14.2              
 system   x86_64, darwin15.6.0        
 ui       X11                         
 language (EN)                        
 collate  en_US.UTF-8                 
 ctype    en_US.UTF-8                 
 tz       America/New_York            
 date     2019-01-11                  

─ Packages ──────────────────────────────────────────────────────────────
 package     * version    date       lib source                           
 assertthat    0.2.0      2017-04-11 [1] CRAN (R 3.5.0)                   
 backports     1.1.2      2017-12-13 [1] CRAN (R 3.5.0)                   
 base64enc     0.1-3      2015-07-28 [1] CRAN (R 3.5.0)                   
 bitops        1.0-6      2013-08-17 [1] CRAN (R 3.5.0)                   
 callr         3.0.0      2018-08-24 [1] CRAN (R 3.5.0)                   
 cli           1.0.1      2018-09-25 [1] CRAN (R 3.5.0)                   
 crayon        1.3.4      2017-09-16 [1] CRAN (R 3.5.0)                   
 desc          1.2.0      2018-10-18 [1] Github (muschellij2/desc@8131d62)
 devtools      2.0.1      2018-10-26 [1] CRAN (R 3.5.0)                   
 digest        0.6.18     2018-10-10 [1] CRAN (R 3.5.0)                   
 evaluate      0.12       2018-10-09 [1] CRAN (R 3.5.0)                   
 fs            1.2.6      2018-08-23 [1] CRAN (R 3.5.0)                   
 glue          1.3.0      2018-07-17 [1] CRAN (R 3.5.0)                   
 htmltools     0.3.6      2017-04-28 [1] CRAN (R 3.5.0)                   
 httr          1.4.0      2018-12-11 [1] CRAN (R 3.5.0)                   
 knitr         1.20       2018-02-20 [1] CRAN (R 3.5.0)                   
 magrittr      1.5        2014-11-22 [1] CRAN (R 3.5.0)                   
 memoise       1.1.0      2017-04-21 [1] CRAN (R 3.5.0)                   
 pkgbuild      1.0.2      2018-10-16 [1] CRAN (R 3.5.0)                   
 pkgload       1.0.2      2018-10-29 [1] CRAN (R 3.5.0)                   
 prettyunits   1.0.2      2015-07-13 [1] CRAN (R 3.5.0)                   
 processx      3.2.0      2018-08-16 [1] CRAN (R 3.5.0)                   
 ps            1.2.1      2018-11-06 [1] CRAN (R 3.5.0)                   
 R6            2.3.0      2018-10-04 [1] CRAN (R 3.5.0)                   
 Rcpp          1.0.0      2018-11-07 [1] CRAN (R 3.5.0)                   
 RCurl         1.95-4.11  2018-07-15 [1] CRAN (R 3.5.0)                   
 remotes       2.0.2      2018-10-30 [1] CRAN (R 3.5.0)                   
 rlang         0.3.0.1    2018-10-25 [1] CRAN (R 3.5.0)                   
 rmarkdown     1.10       2018-06-11 [1] CRAN (R 3.5.0)                   
 rprojroot     1.3-2      2018-01-03 [1] CRAN (R 3.5.0)                   
 Rxnat       * 0.0.0.9006 2019-01-11 [1] Github (adigherman/Rxnat@0aaf382)
 sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 3.5.0)                   
 stringi       1.2.4      2018-07-20 [1] CRAN (R 3.5.0)                   
 stringr       1.3.1      2018-05-10 [1] CRAN (R 3.5.0)                   
 testthat      2.0.1      2018-10-13 [1] CRAN (R 3.5.0)                   
 usethis       1.4.0      2018-08-14 [1] CRAN (R 3.5.0)                   
 withr         2.1.2      2018-03-15 [1] CRAN (R 3.5.0)                   
 yaml          2.2.0      2018-07-25 [1] CRAN (R 3.5.0)                   

[1] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```

# References
