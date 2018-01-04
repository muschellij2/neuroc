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
## Session info -------------------------------------------------------------
```

```
##  setting  value                       
##  version  R version 3.4.3 (2017-11-30)
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  tz       America/New_York            
##  date     2018-01-04
```

```
## Packages -----------------------------------------------------------------
```

```
##  package   * version date       source                            
##  backports   1.1.2   2017-12-13 CRAN (R 3.4.3)                    
##  base      * 3.4.3   2017-12-07 local                             
##  colorout  * 1.1-0   2015-04-20 Github (jalvesaq/colorout@1539f1f)
##  compiler    3.4.3   2017-12-07 local                             
##  datasets  * 3.4.3   2017-12-07 local                             
##  devtools    1.13.4  2017-11-09 CRAN (R 3.4.2)                    
##  digest      0.6.13  2017-12-14 cran (@0.6.13)                    
##  evaluate    0.10.1  2017-06-24 cran (@0.10.1)                    
##  graphics  * 3.4.3   2017-12-07 local                             
##  grDevices * 3.4.3   2017-12-07 local                             
##  htmltools   0.3.6   2017-04-28 CRAN (R 3.4.0)                    
##  knitr       1.18    2017-12-27 CRAN (R 3.4.3)                    
##  magrittr    1.5     2014-11-22 CRAN (R 3.4.0)                    
##  memoise     1.1.0   2017-04-21 CRAN (R 3.4.0)                    
##  methods     3.4.3   2017-12-07 local                             
##  Rcpp        0.12.14 2017-11-23 CRAN (R 3.4.3)                    
##  rmarkdown   1.8     2017-11-17 CRAN (R 3.4.2)                    
##  rprojroot   1.2     2017-01-16 CRAN (R 3.4.0)                    
##  stats     * 3.4.3   2017-12-07 local                             
##  stringi     1.1.6   2017-11-17 CRAN (R 3.4.2)                    
##  stringr     1.2.0   2017-02-18 CRAN (R 3.4.0)                    
##  tools       3.4.3   2017-12-07 local                             
##  utils     * 3.4.3   2017-12-07 local                             
##  withr       2.1.1   2017-12-19 CRAN (R 3.4.3)                    
##  yaml        2.1.16  2017-12-12 cran (@2.1.16)
```

# References
