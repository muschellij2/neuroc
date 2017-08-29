# Preparing Your Package for for Submission
John Muschelli  
`r Sys.Date()`  



All code for this document is located [here](https://github.com/muschellij2/neuroc/blob/master/getting_ready_for_submission/index.Rmd).




# Startup Process

Most of the work we will cover here will get you up and running for submission to our GitHub-based platform.  We will use the devtools package to help us with the process of package development.  If you do not have the package installed, please run:

```r
install.packages("devtools")
```

After `devtools` is installed, you should go through the following process:

1.  [Setting up Git](#version-control-using-git)
2.  [Using GitHub](#hosting-git-repositories-on-github)
3.  [Creating a `README.md` file](#setting-up-a-readme-file)
4.  [Setting up continuous integration: Travis CI and Appveyor](#using-continuous-integration)
5.  [Checking your Package](#checking-your-package)
6.  [Creating a Vignette](#creating-a-vignette)
7.  [Creating Unit Tests using `testthat`](#creating-unit-tests-using-testthat)
8.  [Using Code Coverage](#using-code-coverage)
9.  [Submitting your Package](#submitting-your-package)
10. [Advanced](#advanced)

# Short Version 

The condensed version of this worklow is to run (in R):
```r
devtools::use_git()
devtools::use_github() # must have GITHUB_PAT set up
devtools::use_readme_md()
devtools::use_vignette("my-vignette")
devtools::use_testthat()
devtools::use_coverage(type = "coveralls")
devtools::use_appveyor()
devtools::use_travis()
```

And edit the following files:

## `.travis.yml`

Add (or change in terms of code coverage) the following lines:
```
warnings_are_errors: true 
after_success:
  - Rscript -e 'covr::coveralls(type = "all")'
```
to `.travis.yml`.


## `appveyor.yml`

Add the following lines:
```
environment:
  global:
    WARNINGS_ARE_ERORRS: 1
```
to `appveyor.yml`.

## `README.md`
 
Add the following lines, changing `GITHUB_USERNAME/REPO` to the correct version
```
 [![Travis-CI Build Status] (https://travis-ci.org/GITHUB_USERNAME/REPO.svg?branch=master)] (https://travis-ci.org/GITHUB_USERNAME/REPO)
 [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/GITHUB_USERNAME/REPO?branch=master&svg=true)](https://ci.appveyor.com/project/GITHUB_USERNAME/REPO)
```
to the `README.md`. 

# Version Control using Git 

We will use the [`git` version control system](https://git-scm.com/) for our repositories.  Other version control systems exist, such as Subversion and Mercurial, but we require `git` for our packages as this is the most popular modern version control system.

## Setting up Git

### RStudio 
If you use `RStudio` to set up your packages, please check "Create a git repository" when setting up your package.  Once a repository is set up, you can use the `Tools → Version Control` menu in RStudio for committing and pushing if you do not want to use the command line.

### Using `devtools`

In `R`, you can use `devtools` to set up the `git` repository.  If you are in the root directory of the package (the place with `DESCRIPTION`, `NAMESPACE`, etc. files), you can run:

```r
devtools::use_git()
```

If you would like to pass in the path of the directory instead, use:

```r
devtools::use_git(pkg = "/path/to/repository")
```

Now you should have a folder on your machine (it may be hidden) that stores your commits and changes.

# Hosting Git Repositories on GitHub 

Our platform is based on [GitHub](https://github.com/), which is an online server of the to host `git` repositories.  There are other online repositories for `git`, such as [BitBucket](https://bitbucket.org/) and [GitLab](https://about.gitlab.com).  Although hosting on these repositories should be valid, we currently require all developers to currently host on GitHub.  GitHub is the most popular platform in our experience and all hooks/backend development we use is based on that.  Note, `git` is a system/software, usually installed on your machine, and GitHub is the online server hosting it.  In order to host your repository on GitHub, you must sign up for an account at [https://github.com/](https://github.com/). 

## Setting up GitHub 

### Using the GitHub Website 
In order to set up your repository for GitHub, you can either use the website.  When you are logged into Github, click the plus sign in the top right hand corner <img src="plus.png" style="display: inline; width: 5%">, and then click "New Repository" In the top right hand corner.  We **highly** recommend naming the GitHub repository the same name as the package.

### Using `devtools`

Using `devtools`, you can use the `use_github`.  In order to use this command, you must have a personal access token (PAT) from https://github.com/settings/tokens. Make sure at least the `public_repo` option is checked.  If you have a token set in the `GITHUB_PAT` environment variable, `devtools` will use that.  

If you do not have the `GITHUB_PAT` environment variable set, you must specify `auth_token = "YOUR_TOKEN_HERE"` in the following commands.


If you are in the root directory of the package (the place with `DESCRIPTION`, `NAMESPACE`, etc. files), you can run:

```r
devtools::use_github()
```

If you would like to pass in the path of the directory instead, use:

```r
devtools::use_git(pkg = "/path/to/repository")
```

Check the GitHub website to ensure you have set up your GitHub repository.  You should be able to see the "Push" button enabled when you go to `Tools → Version Control → Commit` in RStudio.


### GitHub Links in your `DESCRIPTION` file

Now that you have GitHub enabled, run:

```r
devtools::use_github_links()
```

so that your "Issues" and "URL" fields are set in `DESCRIPTION` to the GitHub link.

# Setting Up a README file

Once you have your package set up, you should make a `README.md` file.  You can either use a `REAMDE.md` file straight out, without `R` code or a `README.Rmd` file that you knit/render to a `README.md` file.

```r
devtools::use_readme_rmd()
devtools::use_readme_md()
```

The `README.md` file is written in Markdown and you can use the GitHub Markdown flavor. A `REAMDE` file is important because it generates the content at the bottom of a GitHub repository, such as how to install or use the package.  You can also put your badges for number of downloads, version on CRAN (if applicable), [continuous integration](#using-continuous-integration) status, and [code coverage](#using-code-coverage).

# Using Continuous Integration

## Travis

The Travis CI is a [continuous integration](https://en.wikipedia.org/wiki/Continuous_integration) service that we will use to build and check R packages on Linux and Mac OS X operating systems.  In order to use Travis, you must have an account.  We recommend to use [sign in to Travis CI](https://travis-ci.org/auth) with your GitHub account.  You need to authorize Travis CI to have access to your GitHub repositories.  If you have private repositories, those are hosted on https://travis-ci.com, whereas public ones are hosted on https://travis-ci.org.  After authorizing, you should be able to "Sync Accounts" to see your repositories and turn on integration.  

### Configuring Travis 

To create the configuration necessary for Travis CI to build and check the package, the easiest way is to use the `use_travis` command: 

```r
devtools::use_travis()
```

This will add a `.travis.yml` (a [YAML](http://www.yaml.org/start.html) file) file to your folder and added this to your `.Rbuildignore` file.  We recommend adding the following options to your `.travis.yml` file:

```
warnings_are_errors: true
```

so that warnings are treated as errors, which we require in our platform.  

If you would like to test on Mac OSX and Linux (the default is Linux only), addt he following lines.  

```
os:
  - linux
  - osx
```

If you would like to use our platform's customized Travis configuration file, you can use the [YAML file](https://github.com/muschellij2/neuroc_travis/blob/master/neuroc_travis.yml), but make sure you rename it to `.travis.yml` in your folder.  

### Enabling Travis 

Using `use_travis` will open a URL (https://travis-ci.org/GITHUB_USERNAME/REPO) so you can enable Travis to run on this package.  If you use our custom Travis URL, you will have to go that URL yourself.  

In your `README.md`, add the following lines for a travis shield:

```
 [![Travis-CI Build Status] (https://travis-ci.org/GITHUB_USERNAME/REPO.svg?branch=master)] (https://travis-ci.org/GITHUB_USERNAME/REPO)
```

where you change `GITHUB_USERNAME/REPO` to your information.  Once you add/commit the changes to `README.md`, you should have a badge after your package builds to let you know if it passes or fails.

## Appveyor

[Appveyor](https://www.appveyor.com/) is a continuous integration service that builds projects on Windows machines.  Although some packages may not be able to compile on Windows machines, we strive to compile all packages on all 3 main operating systems.  

To enable Appveyor for this repository, the easiest way is to use the `use_appveyor` command: 

```r
devtools::use_appveyor()
```

This will add a `appveyor.yml` YAML file to your folder and added this to your `.Rbuildignore` file.  We recommend adding the following options to your `.travis.yml` file:


```
environment:
  global:
    WARNINGS_ARE_ERORRS: 1
```

so that warnings are treated as errors, which we require in our platform.  

If you would like to use our platform's customized Appveyor configuration file, you can use the [YAML file](https://github.com/muschellij2/neuroc_travis/blob/master/neuroc_appveyor.yml), but make sure you rename it to `appveyor.yml` in your folder.  

### Enabling Appveyor 

You must go to https://ci.appveyor.com/projects/new, go to the repository and then click "Add".  Once you commit and push to the GitHub repository, then Appveyor should build and check your package.


In your `README.md`, add the following lines for a travis shield:

```
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/GITHUB_USERNAME/REPO?branch=master&svg=true)](https://ci.appveyor.com/project/GITHUB_USERNAME/REPO)
```


where you change `GITHUB_USERNAME/REPO` to your information.  Once you add/commit the changes to `README.md`, you should have a badge after your package builds to let you know if it passes or fails.


# Checking your Package

Before you push to GitHub, you can check your package so that all things are in order.  We recommend using `devtools::check(args = "--as-cran")`.  This will check your package and documentation for consistency and inform you of any warnings or errors.  We use the `--as-cran` as it performs checks additional checks similar to CRAN.

If checking in RStudio, you can add this argument in `Build → Configure Build Tools`,  and add `--as-cran` under the "Check options".

You also can do this at the command line using `R CMD check --as-cran`, but you should build a source tarball of your package first.   

# Creating Unit Tests using `testthat`

Unit tests make it easier to identify problems when you make changes to your package.  For example, a new function may work but may not handle a previous case or bug that you had fixed.  Creating a unit test for this bug can ensure that if the output changes to something unexpectedly, you are notified.

We recommend checking out [Hadley Wickham's tutorial](http://r-pkgs.had.co.nz/tests.html) on testing for unit tests.  We recommend using the [`testthat` package](https://cran.r-project.org/web/packages/testthat/index.html).  In order to use the `testthat` package, the easiest way is to use 

```r
devtools::use_testthat()
```

which should make a `tests` folder.  Add as many tests as necessary to try to get your [code coverage](#using-code-coverage) as close to 100\% as possible.

# Creating a Vignette

To make your package more user-friendly (and therefore more likely to be used), we strongly suggest you provide a [vignette](http://r-pkgs.had.co.nz/vignettes.html) with your package.  To create a vignette, run the following command:

```r
devtools::use_vignette("my-vignette")
```

where you'd change `my-vignette` to the **filename** of hte vignette (which means **no spaces!**).  This will create an [R Markdown](http://rmarkdown.rstudio.com/) vignette with the following metadata:

```
---
title: "Vignette Title"
author: "Vignette Author"
date: "2017-08-29"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Vignette Title}
  %\VignetteEngine{knitr::rmarkdown}
  \usepackage[utf8]{inputenc}
---
```

Change the `title: "Vignette Title"` area to have the title you'd like **inside** the document.  You can change the `%\VignetteIndexEntry{Vignette Title}` to the same title; this will be the title of the vignette **in the documentation of the pacakge**.  When you run `browseVignettes("YOUR_PACKAGE")`, the entry there will be pulled from `VignetteIndexEntry`.  

You can make multiple vignettes for the different types of analyses or use cases for your package.

## Building Vignettes

In order to build your vignettes, you can use the following command:


```r
devtools::build_vignettes()
```

# Using Code Coverage

[Code Coverage](https://en.wikipedia.org/wiki/Code_coverage) measures the percentage of code is run when testing occurs.  The `covr` package by Jim Hester provides a great interface for code coverage in R packages.  You can check the code coverage of your package using:

```r
covr::package_coverage()
```

which will provide you with a report.  We suggest adding the argument `type = "all"` so that the code coverage is calculated after going through the unit tests, vignettes, and examples.  The default is to only use the coverage of the unit tests.  Thus, you would run:

```r
covr::package_coverage(type = "all")
```


## Code Coverage and Continuous Integration
The `covr` package also provides an interface for 2 online code coverage tools: [Coveralls](https://coveralls.io/) and  [Codecov](https://codecov.io/).  We use Coveralls as we have had better success setting up the API for our backend, but both are very good.  

To check the code coverage of the package after each build, the easist way is to use `use_coverage`:

```r
devtools::use_coverage(type = "coveralls")
devtools::use_coverage(type = "codecov")
```

where you would use the one whichever service you prefer (they should be the same). This will add the `covr` package to the "Suggests" field of the `DESCRIPTION` (if not in another dependency).  The message states to add:

```
after_success:
  - Rscript -e 'covr::coveralls()'
```

or 
```
after_success:
  - Rscript -e 'covr::codecov()'
```

to the `.travis.yml` file (respective to the service you use).  


We suggest adding the argument `type = "all"` so that the code coverage is calculated after going through the unit tests, vignettes, and examples.  The default is to only use the coverage of the unit tests.  Thus, you would add:

```
after_success:
  - Rscript -e 'covr::coveralls(type = "all")'
```

or 
```
after_success:
  - Rscript -e 'covr::codecov(type = "all")'
```

to the `.travis.yml` file, respectively.


# Submitting your Package

Now that you've performed all the checks and ensured that the package is thoroughly tested, you can submit your package.  Please provide your name, email, and link to the GitHub repository on the [Neuroconductor](https://neuroconductor.org/submit-package) or [OSLER](http://oslerinhealth.org/submit-package) submission pages.  The maintainer of the package will receive and email to verify this is a valid submission and the package will begin [the changes to your package and integration](../continuous_integration/index.html).  

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
