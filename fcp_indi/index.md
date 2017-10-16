# Getting Data from the Functional Connectomes Project (FCP)/INDI
John Muschelli  
`r Sys.Date()`  

All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/fcp_indi/index.R).



# Using the neurohcp package

Although the `neurohcp` package was built specifically for the the [Human Connectome Project](https://www.humanconnectome.org/) (HCP) data, it provides the worker functions for accessing an Amazon S3 bucket and downloading data.  We have adapted these functions to work with the Functional Connectomes Project S3 Bucket (`fcp-indi`) from the INDI initiative.  Although the code is the same, but the bucket is changed, we also must specify we do **not** want to sign the request as `fcp-indi` is an open bucket and the authentication we used for signing fails if we add keys to the data when unneccesary.


# Getting Access to the Data

The data is freelly available;.

# Installing the neurohcp package

We will install the `neurohcp` package using the Neuroconductor installer:

```r
source("http://neuroconductor.org/neurocLite.R")
neuro_install("neurohcp", release = "stable")
```
Once these are set, the functions of neurohcp are ready to use.  To test that the API keys are set correctly, one can run `bucketlist`:


```r
neurohcp::bucketlist(sign = FALSE)
```


```
Warning in neurohcp::bucketlist(verbose = FALSE, sign = FALSE): Response
was html from amazon, returning output rather than parsing
```

```
Response [https://aws.amazon.com/s3/]
  Date: 2017-10-16 18:41
  Status: 200
  Content-Type: text/html;charset=UTF-8
  Size: 281 kB
<!DOCTYPE html>
<html class="no-js aws-lng-en_US" lang="en-US" xmlns="http://www.w3.org/...
 <head> 
  <meta http-equiv="content-type" content="text/html; charset=UTF-8" /> 
  <meta name="viewport" content="width=device-width, initial-scale=1.0" /> 
  <link rel="dns-prefetch" href="https://a0.awsstatic.com" /> 
  <link rel="dns-prefetch" href="//d0.awsstatic.com" /> 
  <link rel="dns-prefetch" href="//d1.awsstatic.com" /> 
  <title>Amazon Simple Storage Service (S3) — Cloud Storage — AWS</title> 
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" /> 
...
```

We see that `fcp-indi` is a bucket that we have access to, and therefore have access to the data.











## Getting Data: Downloading a Directory of Data

In the neurohcp package, there is a data set indicating the scans read for each subject, named `hcp_900_scanning_info`.  We can subset those subjects that have diffusion tensor imaging:


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
Session info -------------------------------------------------------------
```

```
 setting  value                       
 version  R version 3.4.2 (2017-09-28)
 system   x86_64, darwin15.6.0        
 ui       X11                         
 language (EN)                        
 collate  en_US.UTF-8                 
 tz       America/New_York            
 date     2017-10-16                  
```

```
Packages -----------------------------------------------------------------
```

```
 package    * version    date       source                            
 assertthat   0.2.0      2017-04-11 CRAN (R 3.4.0)                    
 backports    1.1.1      2017-09-25 CRAN (R 3.4.2)                    
 base       * 3.4.2      2017-10-04 local                             
 base64enc    0.1-3      2015-07-28 CRAN (R 3.4.0)                    
 bindr        0.1        2016-11-13 CRAN (R 3.4.0)                    
 bindrcpp     0.2        2017-06-17 CRAN (R 3.4.0)                    
 colorout   * 1.1-0      2015-04-20 Github (jalvesaq/colorout@1539f1f)
 compiler     3.4.2      2017-10-04 local                             
 curl         3.0        2017-10-06 CRAN (R 3.4.2)                    
 datasets   * 3.4.2      2017-10-04 local                             
 devtools     1.13.3     2017-08-02 CRAN (R 3.4.1)                    
 digest       0.6.12     2017-01-27 CRAN (R 3.4.0)                    
 dplyr      * 0.7.4      2017-09-28 CRAN (R 3.4.2)                    
 evaluate     0.10.1     2017-06-24 cran (@0.10.1)                    
 glue         1.1.1      2017-06-21 cran (@1.1.1)                     
 graphics   * 3.4.2      2017-10-04 local                             
 grDevices  * 3.4.2      2017-10-04 local                             
 htmltools    0.3.6      2017-04-28 CRAN (R 3.4.0)                    
 httr         1.3.1      2017-08-20 cran (@1.3.1)                     
 knitr        1.17       2017-08-10 cran (@1.17)                      
 magrittr     1.5        2014-11-22 CRAN (R 3.4.0)                    
 memoise      1.1.0      2017-04-21 CRAN (R 3.4.0)                    
 methods      3.4.2      2017-10-04 local                             
 neurohcp   * 0.6        2017-05-14 CRAN (R 3.4.0)                    
 pkgconfig    2.0.1      2017-03-21 CRAN (R 3.4.0)                    
 R6           2.2.2      2017-06-17 CRAN (R 3.4.0)                    
 Rcpp         0.12.13    2017-09-28 cran (@0.12.13)                   
 rlang        0.1.2.9000 2017-09-11 Github (tidyverse/rlang@cf9de64)  
 rmarkdown    1.6        2017-06-15 cran (@1.6)                       
 rprojroot    1.2        2017-01-16 CRAN (R 3.4.0)                    
 stats      * 3.4.2      2017-10-04 local                             
 stringi      1.1.5      2017-04-07 CRAN (R 3.4.0)                    
 stringr      1.2.0      2017-02-18 CRAN (R 3.4.0)                    
 tibble       1.3.4      2017-08-22 cran (@1.3.4)                     
 tools        3.4.2      2017-10-04 local                             
 utils      * 3.4.2      2017-10-04 local                             
 withr        2.0.0      2017-10-05 Github (jimhester/withr@d1f0957)  
 xml2         1.1.9000   2017-09-05 Github (hadley/xml2@5799cd9)      
 yaml         2.1.14     2016-11-12 CRAN (R 3.4.0)                    
```

# References
