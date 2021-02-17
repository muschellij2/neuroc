---
title: "Getting Data from the Human Connectome Project (HCP)"
author: "John Muschelli"
date: "2020-10-02"
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
neuro_install("neurohcp", release = "stable")
```

## Setting the API key

In the `neurohcp` package, `set_aws_api_key` will set the AWS access keys:


```r
set_aws_api_key(access_key = "ACCESS_KEY", secret_key = "SECRET_KEY")
```
or these can be stored in `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` [environment variables](https://stat.ethz.ch/R-manual/R-devel/library/base/html/EnvVar.html), respectively.

Once these are set, the functions of `neurohcp` are ready to use.  To test that the API keys are set correctly, one can run `bucketlist`:


```r
neurohcp::bucketlist()
```


```
                          Bucket             CreationDate
1                 hcp-openaccess 2018-08-13T15:10:17.000Z
2        hcp-openaccess-logfiles 2018-07-25T21:19:33.000Z
3       hcp-openaccess-logs-temp 2018-04-20T15:38:14.000Z
4 hcp-openaccess-logstorage-temp 2018-06-08T15:51:53.000Z
5            hcp-openaccess-test 2018-06-29T13:17:02.000Z
6      hcp-openaccess-trail-temp 2018-04-20T15:43:24.000Z
```

We see that `hcp-openaccess` is a bucket that we have access to, and therefore have access to the data.


## Getting Data: Downloading a Directory of Data

In the `neurohcp` package, there is a data set indicating the scans read for each subject, named `hcp_900_scanning_info`.  We can subset those subjects that have diffusion tensor imaging:


```r
ids_with_dwi = hcp_900_scanning_info %>% 
  filter(scan_type %in% "dMRI") %>% 
  select(id) %>% 
  unique
head(ids_with_dwi)
```

```
# A tibble: 6 x 1
  id    
  <chr> 
1 100307
2 100408
3 101006
4 101107
5 101309
6 101410
```

Let us download the complete directory of diffusion data using `download_hcp_dir`:

```r
r = download_hcp_dir("HCP/100307/T1w/Diffusion", verbose = FALSE)
print(basename(r$output_files))
```

```
[1] "bvals"                   "bvecs"                  
[3] "data.nii.gz"             "grad_dev.nii.gz"        
[5] "nodif_brain_mask.nii.gz"
```
This diffusion data is the data that can be used to create summaries such as fractional anisotropy and mean diffusivity.  

If we create a new column with all the directories, we can iterate over these to download all the diffusion data for these subjects from the HCP database.

```r
ids_with_dwi = ids_with_dwi %>% 
  mutate(id_dir = paste0("HCP/", id, "/T1w/Diffusion"))
```

## Getting Data: Downloading a Single File
We can also download a single file using `download_hcp_file`.  Here we will simply download the `bvals` file:


```r
ret = download_hcp_file("HCP/100307/T1w/Diffusion/bvals", verbose = FALSE)
```



# Session Info


```r
devtools::session_info()
```

```
─ Session info ───────────────────────────────────────────────────────────────
 setting  value                       
 version  R version 4.0.2 (2020-06-22)
 os       macOS Catalina 10.15.6      
 system   x86_64, darwin17.0          
 ui       X11                         
 language (EN)                        
 collate  en_US.UTF-8                 
 ctype    en_US.UTF-8                 
 tz       America/New_York            
 date     2020-10-02                  

─ Packages ───────────────────────────────────────────────────────────────────
 package       * version     date       lib
 assertthat      0.2.1       2019-03-21 [2]
 aws.s3          0.3.21      2020-04-07 [1]
 aws.signature   0.6.0       2020-06-01 [2]
 backports       1.1.10      2020-09-15 [1]
 base64enc       0.1-3       2015-07-28 [2]
 callr           3.4.4       2020-09-07 [1]
 cli             2.0.2       2020-02-28 [2]
 colorout      * 1.2-2       2020-06-01 [2]
 crayon          1.3.4       2017-09-16 [2]
 curl            4.3         2019-12-02 [2]
 desc            1.2.0       2020-06-01 [2]
 devtools        2.3.1.9000  2020-08-25 [2]
 digest          0.6.25      2020-02-23 [2]
 dplyr         * 1.0.2       2020-08-18 [2]
 ellipsis        0.3.1       2020-05-15 [2]
 evaluate        0.14        2019-05-28 [2]
 fansi           0.4.1       2020-01-08 [2]
 fs              1.5.0       2020-07-31 [2]
 generics        0.0.2       2018-11-29 [2]
 glue            1.4.2       2020-08-27 [1]
 htmltools       0.5.0       2020-06-16 [2]
 httr            1.4.2       2020-07-20 [2]
 knitr           1.30        2020-09-22 [1]
 lifecycle       0.2.0       2020-03-06 [2]
 magrittr        1.5         2014-11-22 [2]
 memoise         1.1.0       2017-04-21 [2]
 neurohcp      * 0.9.0       2020-10-01 [1]
 pillar          1.4.6       2020-07-10 [2]
 pkgbuild        1.1.0       2020-07-13 [2]
 pkgconfig       2.0.3       2019-09-22 [2]
 pkgload         1.1.0       2020-05-29 [2]
 prettyunits     1.1.1       2020-01-24 [2]
 processx        3.4.4       2020-09-03 [1]
 ps              1.3.4       2020-08-11 [2]
 purrr           0.3.4       2020-04-17 [2]
 R6              2.4.1       2019-11-12 [2]
 remotes         2.2.0       2020-07-21 [2]
 rlang           0.4.7.9000  2020-09-09 [1]
 rmarkdown       2.3         2020-06-18 [2]
 rprojroot       1.3-2       2018-01-03 [2]
 rstudioapi      0.11        2020-02-07 [2]
 sessioninfo     1.1.1       2018-11-05 [2]
 stringi         1.5.3       2020-09-09 [1]
 stringr         1.4.0       2019-02-10 [2]
 testthat        2.99.0.9000 2020-09-17 [1]
 tibble          3.0.3       2020-07-10 [2]
 tidyselect      1.1.0       2020-05-11 [2]
 usethis         1.6.1.9001  2020-08-25 [2]
 utf8            1.1.4       2018-05-24 [2]
 vctrs           0.3.4       2020-08-29 [1]
 withr           2.3.0       2020-09-22 [1]
 xfun            0.18        2020-09-29 [1]
 xml2            1.3.2       2020-04-23 [2]
 yaml            2.2.1       2020-02-01 [2]
 source                                
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 Github (cloudyr/aws.signature@5689733)
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 Github (jalvesaq/colorout@726d681)    
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 Github (muschellij2/desc@b0c374f)     
 Github (r-lib/devtools@df619ce)       
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 local                                 
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 Github (r-lib/rlang@60c0151)          
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 Github (r-lib/testthat@fbbd667)       
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 Github (r-lib/usethis@860c1ea)        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.2)                        
 CRAN (R 4.0.0)                        
 CRAN (R 4.0.0)                        

[1] /Users/johnmuschelli/Library/R/4.0/library
[2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```

# References
