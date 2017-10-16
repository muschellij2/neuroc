# Getting Data from the Human Connectome Project (HCP)
John Muschelli  
`r Sys.Date()`  

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
                                 Name             CreationDate
1 cf-templates-tgdhg13zvsxm-us-west-2 2017-04-05T20:37:43.000Z
2                      hcp-openaccess 2014-05-15T18:56:50.000Z
3                 hcp-openaccess-logs 2014-05-15T18:57:07.000Z
4                hcp-openaccess-trail 2016-06-02T20:22:11.000Z
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
