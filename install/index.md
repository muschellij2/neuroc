---
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





All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/install/index.R).

# Installing Neuroconductor Packages 

[Install and start the latest release version of R](#installing-and-starting-r).  Although the installer will try to download and install `devtools`, there may be some system requirements for `devtools` that you may need before going forward.  Please visit [installing devtools](../installing_devtools/index.html) before going forward if you do not have `devtools` currently installed. 

Then, you can install a package using the following command:

```r
## try http:// if https:// URLs are supported
source("https://neuroconductor.org/neurocLite.R")
neuro_install("PACKAGE")
```
where `PACKAGE` is the name of the package you'd like to install, such as `fslr`.  For example, if we want to install `neurohcp` and `fslr` we can run:
```r
source("https://neuroconductor.org/neurocLite.R")
neuro_install(c("fslr", "neurohcp"))
```

### Installing the `neurocInstall` package

The `neurocInstall` package contains the `neurocLite`/`neuro_install` functions, as well as others relevant for Neuroconductor.  You can install the package as follows:

```r
source("https://neuroconductor.org/neurocLite.R")
neuro_install("neurocInstall")
```

After installation, you can use `` neurocInstall::neurocLite() `` to install packages without source-ing the URL above.


## Installing Stable/Current/Release Versions

### Stable Versions
In Neuroconductor, there are stable versions, which correspond to a submitted package.  This stable version has passed the Neuroconductor checks on Travis for Linux using the other packages in Neuroconductor that are in Neuroconductor at the time of submission.  Thus, if you install this package with all the dependencies listed for this package (using specific Neuroconductor versions), it should work.

To install a stable version (which should be the default), you can run:

```r
source("https://neuroconductor.org/neurocLite.R")
neuro_install(c("fslr", "neurohcp"), release = "stable")
```

### Current Versions

In Neuroconductor, a "current" version mirrors the repository of the developer of the package.  This does not ensure that the package is passing Neuroconductor checks, but will give you the development version from that developer.  This, at least, standardizes the username for all the repositories in Neuroconductor.  You can install a current version using:

```r
source("https://neuroconductor.org/neurocLite.R")
neuro_install(c("fslr", "neurohcp"), release = "current")
```

### Release Versions

Every few months, we snapshot all of Neuroconductor in their current forms.  We save the source tarballs as well as the binary releases from Travis and Appveyor.  We then host these releases on the Neuroconductor website.  These downloads are stable in time and will not be changed until the next release.  These downloads are also logged to show the activity/amount of use for each package of this release.  To install the release, you would use:

```r
source("https://neuroconductor.org/neurocLite.R")
neuro_install(c("fslr", "neurohcp"), release = "release")
```

See the `release_repo` argument for how to specify which release to use.

### `neurocLite`: an alias for `neuro_install`

As Bioconductor uses the `biocLite` function to install packages, we have created a duplicate of `neuro_install`, called `neurocLite`, for ease of use for those users accustomed to Bioconductor.  The same command could have been executed as follows:
```r
source("https://neuroconductor.org/neurocLite.R")
neurocLite(c("fslr", "neurohcp"))
```


## Installing Neuroconductor Packages without upgrading dependencies

The `neurocLite`/`neuro_install` functions depend on `devtools::install_github`, which will upgrade dependencies by default, which is recommended.  If you would like to install a package, but not upgrade the dependencies (missing dependencies will still be installed), you can set the `upgrade_dependencies` argument to `FALSE`:

```r
neurocLite(c("fslr", "neurohcp"), upgrade_dependencies = FALSE)
```

# Installing and starting R 

1.  Download the most recent version of R from [https://cran.r-project.org/](https://cran.r-project.org/). There are detailed instructions on the R website as well as the specific R installation for the platform you are using, typically Linux, OSX, and Windows.

2.  Start R; we recommend using R through [RStudio](https://www.rstudio.com/).  You can start R using RStudio (Windows, OSX, Linux), typing "R" at in a terminal (Linux or OSX), or using the R application either by double-clicking on the R application (Windows and OSX).

3.  For learning R, there are many resources such as [Try-R at codeschool](http://tryr.codeschool.com/) and [DataCamp](https://www.datacamp.com/getting-started?step=2&track=r).


# Packages not available on Neuroconductor

If a package is not in the Neuroconductor [list of packages ](https://neuroconductor.org/list-packages/all), then it is not located on the [Neuroconductor Github](https://github.com/neuroconductor?tab=repositories).  Therefore, when installing, you'll get the following error:

```r
Error in neuro_install(...) : 
  Package(s) PACKAGE_TRIED_TO_INSTALL are not in neuroconductor
```

Once a package is located on the list of packages, then it will be available to install. 


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
##  date     2021-02-18                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source                            
##  assertthat    0.2.1   2019-03-21 [2] CRAN (R 4.0.0)                    
##  cachem        1.0.4   2021-02-13 [1] CRAN (R 4.0.2)                    
##  callr         3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                    
##  cli           2.3.0   2021-01-31 [1] CRAN (R 4.0.2)                    
##  colorout    * 1.2-2   2020-06-01 [2] Github (jalvesaq/colorout@726d681)
##  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.0.2)                    
##  desc          1.2.0   2020-06-01 [2] Github (muschellij2/desc@b0c374f) 
##  devtools      2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                    
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                    
##  ellipsis      0.3.1   2020-05-15 [2] CRAN (R 4.0.0)                    
##  evaluate      0.14    2019-05-28 [2] CRAN (R 4.0.0)                    
##  fastmap       1.1.0   2021-01-25 [1] CRAN (R 4.0.2)                    
##  fs            1.5.0   2020-07-31 [2] CRAN (R 4.0.2)                    
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                    
##  htmltools     0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)                    
##  knitr         1.31    2021-01-27 [1] CRAN (R 4.0.2)                    
##  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.0.2)                    
##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                    
##  memoise       2.0.0   2021-01-26 [1] CRAN (R 4.0.2)                    
##  pkgbuild      1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                    
##  pkgload       1.1.0   2020-05-29 [2] CRAN (R 4.0.0)                    
##  prettyunits   1.1.1   2020-01-24 [2] CRAN (R 4.0.0)                    
##  processx      3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                    
##  ps            1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                    
##  purrr         0.3.4   2020-04-17 [2] CRAN (R 4.0.0)                    
##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                    
##  remotes       2.2.0   2020-07-21 [2] CRAN (R 4.0.2)                    
##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                    
##  rmarkdown     2.6     2020-12-14 [1] CRAN (R 4.0.2)                    
##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                    
##  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.0.2)                    
##  sessioninfo   1.1.1   2018-11-05 [2] CRAN (R 4.0.0)                    
##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                    
##  stringr       1.4.0   2019-02-10 [2] CRAN (R 4.0.0)                    
##  testthat      3.0.2   2021-02-14 [1] CRAN (R 4.0.2)                    
##  usethis       2.0.1   2021-02-10 [1] CRAN (R 4.0.2)                    
##  withr         2.4.1   2021-01-26 [1] CRAN (R 4.0.2)                    
##  xfun          0.21    2021-02-10 [1] CRAN (R 4.0.2)                    
##  yaml          2.2.1   2020-02-01 [2] CRAN (R 4.0.0)                    
## 
## [1] /Users/johnmuschelli/Library/R/4.0/library
## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```

# References
