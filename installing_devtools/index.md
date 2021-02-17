---
title: "Installing devtools"
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

All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/installing_devtools/index.R).

# First Pass

Overall, RStudio provides a fantastic tutorial and discussion on [installing devtools](https://www.rstudio.com/products/rpackages/devtools/).  Please consult this before the rest of the document.  If you have errors, please see below.



As Neuroconductor is GitHub-based, we will need a way for R to install packages directly from GitHub.  The `devtools` package provides this functionality.  In this tutorial, we will go through the steps of installing `devtools`, and some common problems.  You must have `devtools` installed to install from GitHub in subsequent tutorials on installing Neuroconductor packages.

There are other packages that will do this and are more lightweight (see `remotes` and `ghit`), but we will focus on `devtools`. 


# Mac OSX

You need to install [Command Line Tools](https://developer.apple.com/library/content/technotes/tn2339/_index.html), aka the command line tools for Xcode, if you have not already.  [http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/) is a great tutorial how.

# Installing devtools

If you already have `devtools` installed great! (Why are you in this section?)  You can always reinstall the most up to date version from the steps below.


```r
packages = installed.packages()
packages = packages[, "Package"]
if (!"devtools" %in% packages) {
  install.packages("devtools")
}
```

# The `remotes` and `ghit` packages
If you want a lighter-weight package that has the `install_github` functionality that `devtools` provides, but not all the "development" parts of `devtools`, the `remotes` package exists just for that:


```r
packages = installed.packages()
packages = packages[, "Package"]
if (!"remotes" %in% packages) {
  install.packages("remotes")
}
```

The `ghit` package is the lightest-weight package I have seen which has a `install_github` function, but may have some limited functionality compared to `remotes` in the functionality of installing package with dependencies in other systems, such as BitBucket.

In any subsequent tutorial, when you see `devtools::install_github`, just insert `remotes::install_github` and it should work just the same.


# Updating a package

In the `install_github` function, there are additional options to pass to the `install` function from `devtools`.  One of those arguments is `upgrade_dependencies`, which default is set to `TRUE`.  So if you want to install a package from GitHub, but not update any of the dependencies, then you can use `install_github(..., upgrade_dependencies = FALSE)`.  

# Troubleshooting errors 

## git2r dependency in devtools

If you cannot install `devtools`, many times it is due to `git2r`.  You should look at the installation logs and if you see something like:

```
   The OpenSSL library that is required to
   build git2r was not found.

   Please install:
libssl-dev    (package on e.g. Debian and Ubuntu)
openssl-devel (package on e.g. Fedora, CentOS and RHEL)
openssl       (Homebrew package on OS X)
```

Then run `sudo apt-get libssl-dev` or `sudo yum install openssl-devel` on your respective Linux machine.  Try to re-install `devtools`.

### Mac OSX

For Mac, you have to [install Homebrew](http://www.howtogeek.com/211541/homebrew-for-os-x-easily-installs-desktop-apps-and-terminal-utilities/) which the tutorial is located in the link.  After Homebrew is installed you should be able to type in the Terminal:
```
brew update
brew install openssl
```
Then try to re-install `devtools`.

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

