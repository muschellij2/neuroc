# Continuous Integration
John Muschelli  
`r Sys.Date()`  



All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/continuous_integration/index.R).

For checking R packages, we use [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration) services [Travis CI](https://travis-ci.org/), which builds on Linux and OS X operating systems, and [Appveyor](https://www.appveyor.com/), which builds on Windows using MinGW.  

The purpose is to ensure that the package can be built, installed, and checked on the respective systems with the appropriate dependencies.  

# Travis CI
For Travis CI, we build an initial `.travis.yml` configuration script using `devtools::use_travis()`.   This adds the following to the `.travis.yml`:

```
# R for travis: see documentation at https://docs.travis-ci.com/user/languages/r

language: R
sudo: false
cache: packages
```

We add the following fields to the YAML:

1.  To ensure Bioconductor packages can be installed if necessary:

```
bioc_required: yes
use_bioc: yes
```

2.  So that we ensure that no warnings are present in the installation (similar to CRAN):
```
warnings_are_errors: true
```

3.  That we have a similar threshold for packages similar to CRAN:

```
r_check_args: --as-cran
```

## Future work
In the future, we plan on submitting tagged commits for releases.  We will have built binaries and sources for each version of the package that is submittted.  We also plan to add Neuroconductor badges to the `README.md` file.  


# Appveyor 

Currently, we only support packages that work in *nix type of operatings systems.  We will check the package for Windows as a courtesy to Windows users, but do not provide a detailed level of support.  Moreover, we do not currently support or change appveyor builds to pass for developers.  

For checking, similar to Travis, we use `devtools::use_appveyor()` to generate the `appveyor.yml`, which adds the following:

```

# Download script file from GitHub
init:
  ps: |
        $ErrorActionPreference = "Stop"
        Invoke-WebRequest http://raw.github.com/krlmlr/r-appveyor/master/scripts/appveyor-tool.ps1 -OutFile "..\appveyor-tool.ps1"
        Import-Module '..\appveyor-tool.ps1'

install:
  ps: Bootstrap

cache:
  - C:\RLibrary

# Adapt as necessary starting from here

build_script:
  - travis-tool.sh install_deps

test_script:
  - travis-tool.sh run_tests

on_failure:
  - 7z a failure.zip *.Rcheck\*
  - appveyor PushArtifact failure.zip

artifacts:
  - path: '*.Rcheck\**\*.log'
    name: Logs

  - path: '*.Rcheck\**\*.out'
    name: Logs

  - path: '*.Rcheck\**\*.fail'
    name: Logs

  - path: '*.Rcheck\**\*.Rout'
    name: Logs

  - path: '\*_*.tar.gz'
    name: Bits

  - path: '\*_*.zip'
    name: Bits
```


# Session Info


```r
devtools::session_info()
```

```
## Session info -------------------------------------------------------------
```

```
##  setting  value                       
##  version  R version 3.3.2 (2016-10-31)
##  system   x86_64, darwin13.4.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  tz       America/New_York            
##  date     2017-05-23
```

```
## Packages -----------------------------------------------------------------
```

```
##  package   * version date       source                            
##  backports   1.0.5   2017-01-18 cran (@1.0.5)                     
##  base      * 3.3.2   2016-10-31 local                             
##  colorout  * 1.1-0   2015-04-20 Github (jalvesaq/colorout@1539f1f)
##  datasets  * 3.3.2   2016-10-31 local                             
##  devtools  * 1.13.0  2017-05-08 CRAN (R 3.3.2)                    
##  digest      0.6.12  2017-01-27 cran (@0.6.12)                    
##  evaluate    0.10    2016-10-11 CRAN (R 3.3.0)                    
##  graphics  * 3.3.2   2016-10-31 local                             
##  grDevices * 3.3.2   2016-10-31 local                             
##  htmltools   0.3.6   2016-12-08 Github (rstudio/htmltools@4fbf990)
##  knitr       1.15.1  2016-11-22 CRAN (R 3.3.2)                    
##  magrittr    1.5     2014-11-22 CRAN (R 3.2.0)                    
##  memoise     1.1.0   2017-04-21 cran (@1.1.0)                     
##  methods     3.3.2   2016-10-31 local                             
##  Rcpp        0.12.10 2017-03-19 CRAN (R 3.3.2)                    
##  rmarkdown   1.5     2017-04-26 CRAN (R 3.3.2)                    
##  rprojroot   1.2     2017-01-16 cran (@1.2)                       
##  stats     * 3.3.2   2016-10-31 local                             
##  stringi     1.1.5   2017-04-07 cran (@1.1.5)                     
##  stringr     1.2.0   2017-02-18 cran (@1.2.0)                     
##  tools       3.3.2   2016-10-31 local                             
##  utils     * 3.3.2   2016-10-31 local                             
##  withr       1.0.2   2016-06-20 CRAN (R 3.3.0)                    
##  yaml        2.1.14  2016-11-12 CRAN (R 3.3.2)
```
