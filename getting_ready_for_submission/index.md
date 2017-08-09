# Getting Ready for Submission
John Muschelli  
`r Sys.Date()`  



All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/getting_ready_for_submission/index.R).




# Startup Process

Most of the work we will cover here will get you up and running for submission to our GitHub-based platform.  We will use the devtools package to help us with the process of package development.  If you do not have the package installed, please run:

```r
install.packages("devtools")
```

After `devtools` is installed, you should go through the following process:

1.  Setting up Git
2.  Using GitHub
3.  Creating a `README.md` file
4.  Setting up continuous integration: Travis CI and Appveyor
5.  Creating a Vignette
6.  Creating Unit Tests using `testthat`
7.  Using Code Coverage
8.  Checking your package
9.  Submitting your package to our platform

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

# Hosting Git Repositories GitHub 

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

If you would like to use our platform's customized Travis configuration file, you can use the [Neuroconductor YAML file](https://github.com/muschellij2/neuroc_travis/blob/master/neuroc_travis.yml), but make sure you rename it to `.travis.yml` in your folder.  

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


```r
environment:
  global:
    WARNINGS_ARE_ERORRS: 1
```

so that warnings are treated as errors, which we require in our platform.  

If you would like to use our platform's customized Appveyor configuration file, you can use the [Neuroconductor YAML file](https://github.com/muschellij2/neuroc_travis/blob/master/neuroc_appveyor.yml), but make sure you rename it to `appveyor.yml` in your folder.  

### Enabling Appveyor 

You must go to https://ci.appveyor.com/projects/new, go to the repository and then click "Add".  Once you commit and push to the GitHub repository, then Appveyor should build and check your package.


In your `README.md`, add the following lines for a travis shield:

```
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/GITHUB_USERNAME/REPO?branch=master&svg=true)](https://ci.appveyor.com/project/GITHUB_USERNAME/REPO)
```


where you change `GITHUB_USERNAME/REPO` to your information.  Once you add/commit the changes to `README.md`, you should have a badge after your package builds to let you know if it passes or fails.



# Using Code Coverage




# Session Info


```r
devtools::session_info()
```
