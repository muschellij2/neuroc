---
title: "Continuous Integration and Testing"
author: "John Muschelli"
date: "2020-09-22"
output: 
  html_document:
    keep_md: true
    theme: cosmo
    toc: true
    toc_depth: 3
    toc_float:
      collapsed: false
    number_sections: true      
bibliography: ../refs.bib      
---





All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/continuous_integration_oslerinhealth/index.R).


# Submitting a Package

To submit a package to OSLERinHealth, the author/maintainer of the package provides the GitHub URL for the package.  Once the package is submitted several initial checks are conducted.  These checks ensure that the package has been created correctly.  After  initial checks are complete, the package must be verified by email.  This verification is designed to prevent spam and allow the developer to stop a package if they would like to revise the package before re-submitting.

Once the verification is complete, the package is processed.  Overall, the package is copied/cloned to a remote server.  Standardized Travis CI and Appveyor configuration files, specific to OSLERinHealth, are added.  These are to ensure that the checks performed on these services are consistent for each package.  Some parameters of the package DESCRIPTION file are changed.  These parameters ensure that when a package is downloaded from OSLERinHealth, the correct versions of the dependent packages are used.  

Next, the package is pushed to the central OSLERinHealth GitHub (https://github.com/oslerinhealth) and submitted to Travis CI and AppVeyor to be built and checked on multiple systems.  Parameters are set to ensure that Travis CI and AppVeyor use the correct versions of OSLERinHealth packages for checking and external dependencies are installed. The author of the package receives an automatic email indicating whether the package was built successfully and is integrated with OSLERinHealth together with a description file containing pertinent information about the process. 

## Stable vs. Current Versions

We use the terminology "Stable" and "Current" to differentiate a different status of development for a OSLERinHealth package.  On the initial submission, after all checks are passed, the package is incorporated into OSLERinHealth and deemed the Stable version.  The Current version of the package is the result of nightly pulls and mirror the latest package version from the developer's GitHub repository. This provides OSLERinHealth users with a way to use the latest versions of a package and at the same time it provides the OSLERinHealth platform with a safe way of checking new versions of a package against the existing set of Current OSLERinHealth packages. If a Current version of a package passes all the required OSLERinHealth tests, we contact the developer of the package and suggest an official re-submission to OSLERinHealth. If the newly re-submitted version of the package passes the checks against the Stable OSLERinHealth packages, this version is incorporated to the Stable version of OSLERinHealth.

# The `neuroc.deps` package

We have created the [`neuroc.deps` package](https://github.com/muschellij2/neuroc.deps) that perform most of the backend operations on a OSLERinHealth package.  It can be installed as follows:


```r
devtools::install_github("muschellij2/neuroc.deps")
```

The most relevant function is `use_neuroc_template`, which is used to make many of the changes to the package.  For a specific project, you should specify the `user = "oslerinhealth"`.

# Changes to the `DESCRIPTION` file
In order to test packages against the relevant OSLERinHealth packages, we change the `DESCRIPTION` file.  We do this in the following ways:

1. Modify, or add if not present, the `Remotes` field. Packages are installed using the `install_github` function, which reads this `Remotes` field to install dependencies if necessary. The Remotes field modifies and overrides the locations of dependencies to be installed. If a dependency for a package is present, then a newer version of the package will not be installed unless indicated by the user or indicated a newer version is necessary in the package (by the package (`>= VERSION`)) syntax) in the dependencies.
2. We add the `bioViews` field to a package in case there are Bioconductor package in the dependencies, to ensure `install_github` looks in that repository, as per the issue [hadley/devtools#1254](https://github.com/hadley/devtools/issues/1254).
3. The `covr` package is added to the `Suggests` field if not already present in the dependencies (`Depends`, `Imports`, or `Suggests`).  This is so that code coverage can be performed.  

## ANTsR Dependencies

If a package depends on the `ANTsR` workflow, a slightly modified set of continuous integration steps are performed as that build is highly technical.  

# Continuous Integration Services

For checking R packages, we use [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration) services [Travis CI](https://travis-ci.org/), which builds on Linux and OS X operating systems, and [Appveyor](https://www.appveyor.com/), which builds on Windows using MinGW.  

The purpose is to ensure that the package can be built, installed, and checked on the respective systems with the appropriate dependencies.  

## Travis CI
For Travis CI, we delete the developer's `.travis.yml` configuration script and replace it with the one located at [https://github.com/muschellij2/neuroc.deps/blob/master/inst/oslerinhealth_travis.yml](https://github.com/muschellij2/neuroc.deps/blob/master/inst/oslerinhealth_travis.yml).



### Travis Helpers
```
before_install:
  - fname=travis_helpers.sh
  - wget -O ${fname} http://bit.ly/travis_helpers
  - cat ${fname}; source ${fname}; rm ${fname}  
  - PROJECT_NAME=oslerinhealth
  - remove_neuroc_packages
```
which remove any packages located on OSLERinHealth from the Travis machine.  As caching is done, these may be present from previous builds.  The `travis_helpers.sh` file is a set of helper `bash` functions that backend the [`ghtravis` package](https://github.com/muschellij2/ghtravis).  Most of these are  changes to `DESCRIPTION` file, but on Travis and not the GitHub.

### Installing Remotes without Dependencies

The command:
```
  - install_remotes_no_dep
```

looks at the `Remotes` field in the DESCRIPTION file and runs `install_github(..., upgrade_dependencies = FALSE)`.  This ensures that the OSLERinHealth packages will be those with the specific commit IDs at the time of running.  No old OSLERinHealth packages will be present as they were removed using `remove_neuroc_packages`.

### PACKAGE_NAME environmental variable

The environmental variable of `PACKAGE_NAME` is created from the `DESCRIPTION` file.  This may be different from the repository name from the user, but will be the same repository name on OSLERinHealth, as all repos are `oslerinhealth/PACKAGE_NAME`.

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

When packages are being deployed, `R CMD INSTALL --build` is run so that they have the standardized naming conventions.  The `deployment` information for OSLERinHealth, including GitHub encrypted keys, are added.  After building, the binary distribution is uploaded to the GitHub repository when tagged (from OSLERinHealth's backend not the developer).


### Coverage

After deployment, we use [Coveralls.io](https://coveralls.io/) and the `covr` package to run code coverage.  We use `type = "all"` so that we provide coverage of tests, vignettes, and examples:

```
after_deploy:
  - Rscript -e 'covr::coveralls(type = "all")'
```


### Future work
We plan to add OSLERinHealth badges to the `README.md` file.  


## Appveyor 

Currently, we only formally support packages that work in *nix type of operatings systems.  We will check the package for Windows as a courtesy to Windows users, but do not provide a detailed level of support. 

We use the [oslerinhealth_appveyor.yml](https://github.com/muschellij2/neuroc.deps/blob/master/inst/oslerinhealth_appveyor.yml), which changes the `PATH` variable to try to replicate a Windows machine using Rtools only and not installing MinGW.


Different from the YAML from `devtools::use_appveyor()`, we remove the following part:

```
  - path: '\*_*.tar.gz'
    name: Bits
```
as could overwrite Linux builds depeneding on the naming convention on Deployment.

# Code Coverage

## Coveralls 
We plan to use the [`covr`](https://github.com/jimhester/covr) package to check for code coverage using the [Coveralls](https://coveralls.io/) interface.  We currently do not have any requirements for code coverage for our packages.

# Advanced

## CI and Authentication Tokens

If you need access to a secure key, such as a [GitHub Personal Acccess Token (PAT)](https://github.com/settings/tokens), you **do not to set them in your YAML files**.  Specifically with GitHub, if you push a secure key to a repository, GitHub will automatically deactivate that token (this may only apply to public repositories).  In order to set an environment variable, such as `GITHUB_PAT` for GitHub authentication, you have to change the settings on the repository on the respective CI website.

### Travis CI

In Travis CI you have to go to: https://travis-ci.org/USERNAME/REPO/settings, then the section labeled "Environment Variables".  Put `GITHUB_PAT` as the name and paste your unencrypted GitHub PAT in the Value field.  When you build on Travis CI, you should see:

```
Setting environment variables from repository settings
$ export GITHUB_PAT=[secure]
```

in the build logs.  Now you can use the environment variable `GITHUB_PAT` in your code.  

### Appveyor

In Appveyor you have to go to: https://ci.appveyor.com/project/USERNAME/REPO/settings, then the section labeled "Environment" and click "Add Variable".    Put `GITHUB_PAT` as the name and paste your unencrypted GitHub PAT in the Value field.  I believe you should click the lock to encrypt it. 



# Session Info


```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.2 (2020-06-22)
##  os       macOS Catalina 10.15.6      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/New_York            
##  date     2020-09-22                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version     date       lib source                            
##  assertthat    0.2.1       2019-03-21 [2] CRAN (R 4.0.0)                    
##  backports     1.1.10      2020-09-15 [1] CRAN (R 4.0.2)                    
##  callr         3.4.4       2020-09-07 [1] CRAN (R 4.0.2)                    
##  cli           2.0.2       2020-02-28 [2] CRAN (R 4.0.0)                    
##  colorout    * 1.2-2       2020-06-01 [2] Github (jalvesaq/colorout@726d681)
##  crayon        1.3.4       2017-09-16 [2] CRAN (R 4.0.0)                    
##  desc          1.2.0       2020-06-01 [2] Github (muschellij2/desc@b0c374f) 
##  devtools    * 2.3.1.9000  2020-08-25 [2] Github (r-lib/devtools@df619ce)   
##  digest        0.6.25      2020-02-23 [2] CRAN (R 4.0.0)                    
##  ellipsis      0.3.1       2020-05-15 [2] CRAN (R 4.0.0)                    
##  evaluate      0.14        2019-05-28 [2] CRAN (R 4.0.0)                    
##  fansi         0.4.1       2020-01-08 [2] CRAN (R 4.0.0)                    
##  fs            1.5.0       2020-07-31 [2] CRAN (R 4.0.2)                    
##  glue          1.4.2       2020-08-27 [1] CRAN (R 4.0.2)                    
##  htmltools     0.5.0       2020-06-16 [2] CRAN (R 4.0.0)                    
##  knitr         1.29        2020-06-23 [2] CRAN (R 4.0.2)                    
##  lifecycle     0.2.0       2020-03-06 [2] CRAN (R 4.0.0)                    
##  magrittr      1.5         2014-11-22 [2] CRAN (R 4.0.0)                    
##  memoise       1.1.0       2017-04-21 [2] CRAN (R 4.0.0)                    
##  pkgbuild      1.1.0       2020-07-13 [2] CRAN (R 4.0.2)                    
##  pkgload       1.1.0       2020-05-29 [2] CRAN (R 4.0.0)                    
##  prettyunits   1.1.1       2020-01-24 [2] CRAN (R 4.0.0)                    
##  processx      3.4.4       2020-09-03 [1] CRAN (R 4.0.2)                    
##  ps            1.3.4       2020-08-11 [2] CRAN (R 4.0.2)                    
##  purrr         0.3.4       2020-04-17 [2] CRAN (R 4.0.0)                    
##  R6            2.4.1       2019-11-12 [2] CRAN (R 4.0.0)                    
##  remotes       2.2.0       2020-07-21 [2] CRAN (R 4.0.2)                    
##  rlang         0.4.7.9000  2020-09-09 [1] Github (r-lib/rlang@60c0151)      
##  rmarkdown     2.3         2020-06-18 [2] CRAN (R 4.0.0)                    
##  rprojroot     1.3-2       2018-01-03 [2] CRAN (R 4.0.0)                    
##  rstudioapi    0.11        2020-02-07 [2] CRAN (R 4.0.0)                    
##  sessioninfo   1.1.1       2018-11-05 [2] CRAN (R 4.0.0)                    
##  stringi       1.5.3       2020-09-09 [1] CRAN (R 4.0.2)                    
##  stringr       1.4.0       2019-02-10 [2] CRAN (R 4.0.0)                    
##  testthat      2.99.0.9000 2020-09-17 [1] Github (r-lib/testthat@fbbd667)   
##  usethis     * 1.6.1.9001  2020-08-25 [2] Github (r-lib/usethis@860c1ea)    
##  withr         2.2.0       2020-04-20 [2] CRAN (R 4.0.0)                    
##  xfun          0.17        2020-09-09 [1] CRAN (R 4.0.2)                    
##  yaml          2.2.1       2020-02-01 [2] CRAN (R 4.0.0)                    
## 
## [1] /Users/johnmuschelli/Library/R/4.0/library
## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
