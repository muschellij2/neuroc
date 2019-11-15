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





All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/install_oslerinhealth/index.R).

# Installing OSLERinHealth Packages 

[Install and start the latest release version of R](#installing-and-starting-r).  Although the installer will try to download and install `devtools`, there may be some system requirements for `devtools` that you may need before going forward.  Please visit [installing devtools](../installing_devtools/index.html) before going forward if you do not have `devtools` currently installed. 

Then, you can install a package using the following command:

```r
## try http:// if https:// URLs are supported
source("http://oslerinhealth.org/oslerLite.R")
osler_install("PACKAGE")
```
where `PACKAGE` is the name of the package you'd like to install, such as `baker`.  For example, if we want to install `spotgear` and `baker` we can run:
```r
source("http://oslerinhealth.org/oslerLite.R")
osler_install(c("baker", "spotgear"))
```

### Installing the `oslerInstall` package

The `oslerInstall` package contains the `oslerLite`/`osler_install` functions, as well as others relevant for OSLERinHealth.  You can install the package as follows:

```r
source("http://oslerinhealth.org/oslerLite.R")
osler_install("oslerInstall")
```

After installation, you can use `` oslerInstall::oslerLite() `` to install packages without source-ing the URL above.


## Installing Stable/Current/Release Versions

### Stable Versions
In OSLERinHealth, there are stable versions, which correspond to a submitted package.  This stable version has passed the OSLERinHealth checks on Travis for Linux using the other packages in OSLERinHealth that are in OSLERinHealth at the time of submission.  Thus, if you install this package with all the dependencies listed for this package (using specific OSLERinHealth versions), it should work.

To install a stable version (which should be the default), you can run:

```r
source("http://oslerinhealth.org/oslerLite.R")
osler_install(c("baker", "spotgear"), release = "stable")
```

### Current Versions

In OSLERinHealth, a "current" version mirrors the repository of the developer of the package.  This does not ensure that the package is passing OSLERinHealth checks, but will give you the development version from that developer.  This, at least, standardizes the username for all the repositories in OSLERinHealth.  You can install a current version using:

```r
source("http://oslerinhealth.org/oslerLite.R")
osler_install(c("baker", "spotgear"), release = "current")
```

### Release Versions

Every few months, we snapshot all of OSLERinHealth in their current forms.  We save the source tarballs as well as the binary releases from Travis and Appveyor.  We then host these releases on the OSLERinHealth website.  These downloads are stable in time and will not be changed until the next release.  These downloads are also logged to show the activity/amount of use for each package of this release.  To install the release, you would use:

```r
source("http://oslerinhealth.org/oslerLite.R")
osler_install(c("baker", "spotgear"), release = "release")
```

See the `release_repo` argument for how to specify which release to use.

### `oslerLite`: an alias for `osler_install`

As Bioconductor uses the `biocLite` function to install packages, we have created a duplicate of `osler_install`, called `oslerLite`, for ease of use for those users accustomed to Bioconductor.  The same command could have been executed as follows:
```r
source("http://oslerinhealth.org/oslerLite.R")
oslerLite(c("baker", "spotgear"))
```


## Installing OSLERinHealth Packages without upgrading dependencies

The `oslerLite`/`osler_install` functions depend on `devtools::install_github`, which will upgrade dependencies by default, which is recommended.  If you would like to install a package, but not upgrade the dependencies (missing dependencies will still be installed), you can set the `upgrade_dependencies` argument to `FALSE`:

```r
oslerLite(c("baker", "spotgear"), upgrade_dependencies = FALSE)
```

# Installing and starting R 

1.  Download the most recent version of R from [https://cran.r-project.org/](https://cran.r-project.org/). There are detailed instructions on the R website as well as the specific R installation for the platform you are using, typically Linux, OSX, and Windows.

2.  Start R; we recommend using R through [RStudio](https://www.rstudio.com/).  You can start R using RStudio (Windows, OSX, Linux), typing "R" at in a terminal (Linux or OSX), or using the R application either by double-clicking on the R application (Windows and OSX).

3.  For learning R, there are many resources such as [Try-R at codeschool](http://tryr.codeschool.com/) and [DataCamp](https://www.datacamp.com/getting-started?step=2&track=r).


# Packages not available on OSLERinHealth

If a package is not in the OSLERinHealth [list of packages ](http://oslerinhealth.org/list-packages/all), then it is not located on the [OSLERinHealth Github](https://github.com/oslerinhealth?tab=repositories).  Therefore, when installing, you'll get the following error:

```r
Error in osler_install(...) : 
  Package(s) PACKAGE_TRIED_TO_INSTALL are not in oslerinhealth
```

Once a package is located on the list of packages, then it will be available to install. 


# Session Info


```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.6        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/New_York            
##  date     2019-11-14                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version     date       lib
##  assertthat    0.2.1       2019-03-21 [1]
##  backports     1.1.5       2019-10-02 [1]
##  callr         3.3.2       2019-09-22 [1]
##  cli           1.1.0       2019-03-19 [1]
##  colorout    * 1.2-1       2019-06-19 [1]
##  crayon        1.3.4       2017-09-16 [1]
##  desc          1.2.0       2019-07-10 [1]
##  devtools      2.2.0.9000  2019-09-10 [1]
##  digest        0.6.22      2019-10-21 [1]
##  DT            0.8         2019-08-07 [1]
##  ellipsis      0.3.0       2019-09-20 [1]
##  evaluate      0.14        2019-05-28 [1]
##  fs            1.3.1       2019-05-06 [1]
##  glue          1.3.1       2019-03-12 [1]
##  htmltools     0.4.0       2019-10-04 [1]
##  htmlwidgets   1.5.1       2019-10-08 [1]
##  knitr         1.24.3      2019-08-28 [1]
##  magrittr      1.5         2014-11-22 [1]
##  memoise       1.1.0       2017-04-21 [1]
##  pkgbuild      1.0.5       2019-08-26 [1]
##  pkgload       1.0.2       2018-10-29 [1]
##  prettyunits   1.0.2       2015-07-13 [1]
##  processx      3.4.1       2019-07-18 [1]
##  ps            1.3.0       2018-12-21 [1]
##  R6            2.4.1       2019-11-12 [1]
##  Rcpp          1.0.3       2019-11-08 [1]
##  remotes       2.1.0       2019-06-24 [1]
##  rlang         0.4.1       2019-10-24 [1]
##  rmarkdown     1.16        2019-10-01 [1]
##  rprojroot     1.3-2       2018-01-03 [1]
##  rstudioapi    0.10.0-9001 2019-09-10 [1]
##  sessioninfo   1.1.1       2018-11-05 [1]
##  stringi       1.4.3       2019-03-12 [1]
##  stringr       1.4.0       2019-02-10 [1]
##  testthat      2.2.1       2019-07-25 [1]
##  usethis       1.5.1.9000  2019-08-15 [1]
##  withr         2.1.2       2018-03-15 [1]
##  xfun          0.11        2019-11-12 [1]
##  yaml          2.2.0       2018-07-25 [1]
##  source                             
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  Github (jalvesaq/colorout@7ea9440) 
##  CRAN (R 3.6.0)                     
##  Github (muschellij2/desc@b0c374f)  
##  Github (r-lib/devtools@d7f0915)    
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  Github (muschellij2/knitr@abcea3d) 
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  Github (rstudio/rstudioapi@a7143c5)
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  local                              
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
##  CRAN (R 3.6.0)                     
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```

# References
