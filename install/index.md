


All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/install/index.R).

# Installing Neuroconductor Packages 

[Install and start the latest release version of R](#installing-and-starting-r) and then you can install a package using the following command:


```r
## try https:// if http:// URLs are supported
source("http://neuroconductor.org/neurocLite.R")
neuro_install("PACKAGE")
```
where `PACKAGE` is the name of the package you'd like to install, such as `fslr`.  For example, if we want to install `hcp` and `fslr` we can run:

```r
source("http://neuroconductor.org/neurocLite.R")
neuro_install(c("fslr", "hcp"))
```
### `neurocLite`: an alias for `neuroc_install`

As Bioconductor uses the `biocLite` function to install packages, we have created a duplicate of `neuro_install`, called `neurocLite`, for ease of use for those users accustomed to Bioconductor.  The same command could have been executed as follows:

```r
source("http://neuroconductor.org/neurocLite.R")
neurocLite(c("fslr", "hcp"))
```

### Installing the `neurocInstall` package

The `neurocInstall` package contains the `neurocLite`/`neuro_install` functions, as well as others relevant for Neuroconductor.  You can install the package as follows:


```r
source("http://neuroconductor.org/neurocLite.R")
neuro_install("neurocInstall")
```

After installation, you can use `neurocInstall::neuroc_install()` to install packages without source-ing the URL above.

## Installing Neuroconductor Packages without upgrading dependencies

The `neurocLite`/`neuro_install` functions depend on `devtools::install_github`, which will upgrade dependencies by default, which is recommended.  If you would like to install a package, but not upgrade the dependencies (missing dependencies will still be installed), you can set the `upgrade_dependencies` argument to `FALSE`:


```r
neurocLite(c("fslr", "hcp"), upgrade_dependencies = FALSE)
```

# Installing and starting R 

1.  Download the most recent version of R from [https://cran.r-project.org/](https://cran.r-project.org/). There are detailed instructions on the R website as well as the specific R installation for the platform you are using, typically Linux, OSX, and Windows.

2.  Start R; we recommend using R through [RStudio](https://www.rstudio.com/).  You can start R using RStudio (Windows, OSX, Linux), typing "R" at in a terminal (Linux or OSX), or using the R application either by double-clicking on the R application (Windows and OSX).

3.  For learning R, there are many resources such as [Try-R at codeschool](http://tryr.codeschool.com/) and [DataCamp](https://www.datacamp.com/getting-started?step=2&track=r).


# Packages not available on Neuroconductor

If a package is not in the Neuroconductor [list of packages ](http://neuroconductor.org/list-current-packages), then it is not located on the [Neuroconductor Github](https://github.com/neuroconductor?tab=repositories).  Therefore, when installing, you'll get the following error:

```
Error in neuro_install(...) : 
  Package(s) PACKAGE_TRIED_TO_INSTALL are not in neuroconductor
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
##  version  R version 3.3.1 (2016-06-21)
##  system   x86_64, darwin13.4.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  tz       America/New_York            
##  date     2016-12-21
```

```
## Packages -----------------------------------------------------------------
```

```
##  package   * version     date       source                            
##  backports   1.0.4       2016-10-24 CRAN (R 3.3.0)                    
##  colorout  * 1.1-0       2015-04-20 Github (jalvesaq/colorout@1539f1f)
##  devtools    1.12.0.9000 2016-12-08 Github (hadley/devtools@1ce84b0)  
##  digest      0.6.10      2016-08-02 cran (@0.6.10)                    
##  evaluate    0.10        2016-10-11 CRAN (R 3.3.0)                    
##  htmltools   0.3.6       2016-12-08 Github (rstudio/htmltools@4fbf990)
##  knitr       1.15.1      2016-11-22 cran (@1.15.1)                    
##  magrittr    1.5         2014-11-22 CRAN (R 3.2.0)                    
##  memoise     1.0.0       2016-01-29 CRAN (R 3.2.3)                    
##  pkgbuild    0.0.0.9000  2016-12-08 Github (r-pkgs/pkgbuild@65eace0)  
##  pkgload     0.0.0.9000  2016-12-08 Github (r-pkgs/pkgload@def2b10)   
##  Rcpp        0.12.8.2    2016-12-08 Github (RcppCore/Rcpp@8c7246e)    
##  rmarkdown   1.2.9000    2016-12-08 Github (rstudio/rmarkdown@7a3df75)
##  rprojroot   1.1         2016-10-29 cran (@1.1)                       
##  stringi     1.1.2       2016-10-01 CRAN (R 3.3.0)                    
##  stringr     1.1.0       2016-08-19 cran (@1.1.0)                     
##  withr       1.0.2       2016-06-20 CRAN (R 3.3.0)                    
##  yaml        2.1.14      2016-11-12 CRAN (R 3.3.2)
```

# References
