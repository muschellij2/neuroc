# Continuous Integration and Testing
John Muschelli  
`r Sys.Date()`  



All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/continuous_integration/index.R).

# The `neuroc.deps` package

We have created the [`neuroc.deps` package](https://github.com/muschellij2/neuroc.deps) that perform most of the backend operations on a Neuroconductor package.  It can be installed as follows:


```r
devtools::install_github("muschellij2/neuroc.deps")
```

The most relevant function is `use_neuroc_template`, which is used to make many of the changes to the package.

# Changes to the `DESCRIPTION` file
In order to test packages against the relevant Neuroconductor packages, we change the `DESCRIPTION` file.  We do this in the following ways:

1. Modify, or add if not present, the `Remotes` field. Packages are installed using the `install_github` function, which reads this `Remotes` field to install dependencies if necessary. The Remotes field modifies and overrides the locations of dependencies to be installed. If a dependency for a package is present, then a newer version of the package will not be installed unless indicated by the user or indicated a newer version is necessary in the package (by the package (`>= VERSION`)) syntax) in the dependencies.
2. We add the `bioViews` field to a package in case there are Bioconductor package in the dependencies, to ensure `install_github` looks in that repository, as per the issue [hadley/devtools#1254](https://github.com/hadley/devtools/issues/1254).
3. The `covr` package is added to the `Suggests` field if not already present in the dependencies (`Depends`, `Imports`, or `Suggests`).  This is so that code coverage can be performed.  

## ANTsR Dependencies

If a package depends on the `ANTsR` workflow, a slightly modified set of continuous integration steps are performed as that build is highly technical.  

# Continuous Integration Services

For checking R packages, we use [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration) services [Travis CI](https://travis-ci.org/), which builds on Linux and OS X operating systems, and [Appveyor](https://www.appveyor.com/), which builds on Windows using MinGW.  

The purpose is to ensure that the package can be built, installed, and checked on the respective systems with the appropriate dependencies.  

## Travis CI
For Travis CI, we delete the developer's `.travis.yml` configuration script and replace it with the one located at [https://github.com/muschellij2/neuroc.deps/blob/master/inst/neuroc_travis.yml](https://github.com/muschellij2/neuroc.deps/blob/master/inst/neuroc_travis.yml).



### Travis Helpers
```
before_install:
  - fname=travis_helpers.sh
  - wget -O ${fname} http://bit.ly/travis_helpers
  - cat ${fname}; source ${fname}; rm ${fname}  
  - remove_neuroc_packages
```
which remove any packages located on Neuroconductor from the Travis machine.  As caching is done, these may be present from previous builds.  The `travis_helpers.sh` file is a set of helper `bash` functions that backend the [`ghtravis` package](https://github.com/muschellij2/ghtravis).  Most of these are  changes to `DESCRIPTION` file, but on Travis and not the GitHub.

### Installing Remotes without Dependencies

The command:
```
  - install_remotes_no_dep
```

looks at the `Remotes` field in the DESCRIPTION file and runs `install_github(..., upgrade_dependencies = FALSE)`.  This ensures that the Neuroconductor packages will be those with the specific commit IDs at the time of running.  No old Neuroconductor packages will be present as they were removed using `remove_neuroc_packages`.

### PACKAGE_NAME environmental variable

The environmental variable of `PACKAGE_NAME` is created from the `DESCRIPTION` file.  This may be different from the repository name from the user, but will be the same repository name on Neuroconductor, as all repos are `neuroconductor/PACKAGE_NAME`.

```
  - export PACKAGE_NAME=`package_name`
```

### Bioconductor Packages

We add the following fields to the YAML:
To ensure Bioconductor packages can be installed if necessary:

```
bioc_required: yes
use_bioc: yes
```

### Warnings are Errors
So that we ensure that no warnings are present in the installation (similar to CRAN):
```
warnings_are_errors: true
```

### CRAN checks 

That we have a similar threshold for packages similar to CRAN:

```
r_check_args: --as-cran
```

### Pass or Fail

After running `R CMD check`, the `00install.out` and `00check.log` are printed for diagnostic purposes.

### Deployment 

When packages are being deployed, `R CMD INSTALL --build` is run so that they have the standardized naming conventions.  The `deployment` information for neuroconductor, including GitHub encrypted keys, are added.  After building, the binary distribution is uploaded to the GitHub repository when tagged (from Neuroconductor's backend not the developer).


### Coverage

After deployment, we use [Coveralls.io](https://coveralls.io/) and the `covr` package to run code coverage.  We use `type = "all"` so that we provide coverage of tests, vignettes, and examples:

```
after_deploy:
  - Rscript -e 'covr::coveralls(type = "all")'
```


### Future work
We plan to add Neuroconductor badges to the `README.md` file.  


## Appveyor 

Currently, we only formally support packages that work in *nix type of operatings systems.  We will check the package for Windows as a courtesy to Windows users, but do not provide a detailed level of support. 

We use the [neuroc_appveyor.yml](https://github.com/muschellij2/neuroc.deps/blob/master/inst/neuroc_appveyor.yml), which changes the `PATH` variable to try to replicate a Windows machine using Rtools only and not installing MinGW.


Different from the YAML from `devtools::use_appveyor()`, we remove the following part:

```
  - path: '\*_*.tar.gz'
    name: Bits
```
as could overwrite Linux builds depeneding on the naming convention on Deployment.

# Code Coverage

## Coveralls 
We plan to use the [`covr`](https://github.com/jimhester/covr) package to check for code coverage using the [Coveralls](https://coveralls.io/) interface.  We currently do not have any requirements for code coverage for our packages.

# Session Info


```r
devtools::session_info()
```

```
## Session info -------------------------------------------------------------
```

```
##  setting  value                       
##  version  R version 3.4.1 (2017-06-30)
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  tz       America/New_York            
##  date     2017-08-08
```

```
## Packages -----------------------------------------------------------------
```

```
##  package   * version     date       source                            
##  backports   1.1.0       2017-05-22 CRAN (R 3.4.0)                    
##  base      * 3.4.1       2017-07-07 local                             
##  colorout  * 1.1-0       2015-04-20 Github (jalvesaq/colorout@1539f1f)
##  compiler    3.4.1       2017-07-07 local                             
##  datasets  * 3.4.1       2017-07-07 local                             
##  devtools  * 1.13.2.9000 2017-07-12 Github (hadley/devtools@d3482c5)  
##  digest      0.6.12      2017-01-27 CRAN (R 3.4.0)                    
##  evaluate    0.10.1      2017-06-24 cran (@0.10.1)                    
##  graphics  * 3.4.1       2017-07-07 local                             
##  grDevices * 3.4.1       2017-07-07 local                             
##  htmltools   0.3.6       2017-04-28 CRAN (R 3.4.0)                    
##  knitr       1.16        2017-05-18 CRAN (R 3.4.0)                    
##  magrittr    1.5         2014-11-22 CRAN (R 3.4.0)                    
##  memoise     1.1.0       2017-04-21 CRAN (R 3.4.0)                    
##  methods     3.4.1       2017-07-07 local                             
##  pkgbuild    0.0.0.9000  2017-07-12 Github (r-pkgs/pkgbuild@8aab60b)  
##  pkgload     0.0.0.9000  2017-07-06 Github (r-pkgs/pkgload@119cf9a)   
##  Rcpp        0.12.12     2017-07-15 cran (@0.12.12)                   
##  rlang       0.1.1.9000  2017-07-24 Github (hadley/rlang@342c473)     
##  rmarkdown   1.6         2017-06-15 cran (@1.6)                       
##  rprojroot   1.2         2017-01-16 CRAN (R 3.4.0)                    
##  stats     * 3.4.1       2017-07-07 local                             
##  stringi     1.1.5       2017-04-07 CRAN (R 3.4.0)                    
##  stringr     1.2.0       2017-02-18 CRAN (R 3.4.0)                    
##  tools       3.4.1       2017-07-07 local                             
##  utils     * 3.4.1       2017-07-07 local                             
##  withr       1.0.2       2016-06-20 CRAN (R 3.4.0)                    
##  yaml        2.1.14      2016-11-12 CRAN (R 3.4.0)
```
