---
title: "Painlessly Building R Packages"
author: "John Muschelli"
date: "2018-03-27"
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



All code for this document is located [here](https://github.com/muschellij2/neuroc/blob/master/r_package_workflow/index.Rmd).




# Simple Script to Start a Package

Most of the work we will cover here will get you up and running for submission to our GitHub-based platform.  We will use the following packages:

1. `devtools` which has a large set of functions for building and checking package
2. `usethis` functions to help us with creating additional things like the `README` file and adding things for GitHub.  
3. `muschflow` - a workflow package I use for my pipeline that wraps `usethis`.

In the code below, change `"/path/to/packages"` to the path where you want the package to be created.  The package itself will be a sub-folder of this folder.   The script will change directories and then install the necessary packages:

```r
setwd("/path/to/packages")
if (!"devtools" %in% installed.packages()){
  install.packages("devtools")
}
if (!"usethis" %in% installed.packages()){
  install.packages("usethis")
}
if (!"muschflow" %in% installed.packages()){
  devtools::install_github("muschellij2/muschflow")
}
library(devtools)
library(muschflow)
```

The following code will make the package folder.  You should change `"mypackage"` to the package name you want to call the package.  

```r
pkgname = "mypackage"
devtools::create(pkgname)
setwd(pkgname)
```

A folder named `R` is now is in the package directory.  On the top right of `RStudio`, you should see a `Project: (None)` dropdown.  If you choose `Open Project` and choose `mypackage.Rproj`, it will open a new `RStudio` session.

As long as you're in that directory, you can run the following code even if not in the `RStudio` project. 


You should also add information in the `title` and `description` fields in the `muschelli_workflow` function.  Titles should be "title case" (e.g. `Creates Fun Plots for Analysis`) and **not** start with words like "A Package" or "Functions to".   The `description` argument should be written like prose `"Creates fun plots for analysis in everyday situations."`  It should end with a period like normal sentences.

```r
coverage_type = "coveralls"
usethis::use_git()
muschflow::muschelli_workflow(
  title = "Creates Fun Plots for Analysis", 
  description = "Creates fun plots for analysis in everyday situations.", 
  coverage_type = coverage_type)
```

Now copy your R scripts with functions to the `R/` sub-folder. 


# "Manual" Workflow for an `R` package

I'm assuming your `R` code is already available, presumably functions you had created during a project or analysis.  If code is not available, GREAT!  You can start your workflow for your new package or product all the same.  I'll try to put command-line equivalents in double brackets [[ ]].

Workflow:

1.  Start RStudio.
2.  Go to `File -> New Project`.  (Save any unsaved work).
3.  Select `New Directory`.  Now this may be counterintuitive if you have work saved, but if you're creating a package choose this.  This will setup a new folder and copy over any code you have already created.
4.  Select `R Package`.  This will allow you to name your package (it will be used in the `library` statement unless changed later); let's call it `mypckg`.  You can also choose code you have to operationalize, e.g. put into a package.  Also - select you want to create a git repository.  
5.  Voila! The folder is created where you have the components of an `R` package, such as the documentation (`man`), extra install dir (`inst`), the `R` code (`R`), etc.  [[`library(devtools); create("mypckg");`]]

Now, here is one of the main reasons I like using RStudio for projects: the `.Rproj` file.  The `.Rproj` file is an RStudio project file.  It allows you to work on stuff in multiple tabs/scripts, then close the project, and pop up the other tabs/scripts you were working on before opening up that project.  If you are in RStudio, the top right should show a `Project: None` if you don't have a project loaded.  These project files allows me to segregate my workflows and scripts, and they help me organize a bit more.  I highly recommend checking out [Hilary Parker's post](http://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/) before continuing, especially if you're not an RStudio fan.

### Using RStudio Build Tools
Now, when I say RStudio Build Tools, I essentially mean wrappers for the [`devtools`](https://github.com/hadley/devtools) package.  The package is amazing (hardly shocking since Hadley Wickham is the main author), and along with the `roxygen2` package, allow package creation to be as easy as possible. 

Now, let's set up our options for Build Tools.  In RStudio, go to `Build -> Configure Build Tools` (again you must be in an RStudio project).  For `Check Package`, I recommend putting the `--as-cran` option (especially if you plan to [submit to CRAN](http://cran.r-project.org/web/packages/policies.html).  You should also see a checkbox saying `Generate documentation using Roxygen`. If this is not available, run `install.packages("roxygen2")`, close and reopen the project.  Check this box, and click the `Configure` button and I usually click all options.  


### Setting up a remote git repository
Before, we checked for a git repository to be created.  Now, you can create a new repository in your favorite GitHub remote repository.  Mine is [GitHub](http://www.github.com).  You can use the GUIs such as the GitHub GUI or SourceTree, but I generally set this up using the Terminal by just [adding the remote](https://help.github.com/articles/adding-a-remote).  ([Here](https://help.github.com/articles/generating-ssh-keys) is a link to create ssh keys so you don't have to type in passwords for git).  Now, if you restarted the RStudio project, go to `Build -> Configure Build Tools` and you should see the remote repository if you click the `Git/SVN` tab.  

Now that the repository is set up (even if you don't use a remote repository), you can go to `Tools --> Commit` to commit to the repository.  This allows you to add and stage the changed files while adding a commit comment.  You can also see a visual history of the differences and changes as well as do much of what you would need to from the command line.  Again, I like the Terminal, but I like having this all in one program and not having to switch back and forth.  

# DOCUMENTATION!  EXAMPLES!  VIGNETTES!
Now that you have everything set up, you have to do the big things that differentiate a bunch of functions from a package: documentation and examples (including vignettes).  Again, for documentation, we'll be using the `roxygen2` package.  Roxygen is essentially a format that starts with a line with `#' ` followed by `@` followed by a "tag".  The tags can be found at `?rd_roclet`.  Now, I highly recommend vignettes, but I'm not an expert on these and think we'll just stick to function docs right now.

## Creating Roxygen Tags
Before we start documentation, let me again tell about MY workflow rather than Roxygen.  Now we can open a R script with functions in there.  Select the function definition such as `x = function(z, y, l=4, ...){` and go to the `Code → Insert Roxygen Skeleton` to create Roxygen tags!  

```
#' Title
#'
#' @param z 
#' @param y 
#' @param l 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
x = function(z, y, l=4, ...){
}
```

One thing to note is that RStudio will assume you're trying to stay in Roxygen notation with a return of line (which is great for multi-line descriptions/titles/etc).  Also, if you have `#' @` starting a line, then RStudio will do tab completion of Roxygen tags.  Not leaps and bounds saved on time, but hey, I like tab completion.  

Now you have to write your examples, the description of arguments (denoted as parameters), the overall function description and title, and  use the `@export` to allow this function accessible to the user.  One note is that if you depend on another function or package, use the `@import pkgname` or `@importsFrom pkgname funcName funcName2` tags.  `R CMD check` will warn you if you don't have anything in `@examples`, so remove these if not necessary (they usually are though).

## Just let me check my functions!
If you're still working on the package and want to play with functions and no so much the documentation, you can use `Build -> Load All` [[`devtools::load_all`]] to load the functions (even those not exported) into memory.  

## Compile and Load
Now let's fast-forward to when you have created the the documentation for your functions.  While still in your project, go to `Build -> Build and Reload` to get your package loaded into memory [[`devtools::build` then `devtools::install`]].  Roxygen will create the docs. FYI - if you change around function names and recompile, the `man` folder may have obsolete `.Rd` files, so you can delete old ones.  

You should edit the `DESCRIPTION` file to change some specifications, such as `Depends:` fields for package dependencies. That's documented many places on the web to find about what goes in there.

Now edit your functions and docs, push to the remote repository and then allow people install your package by using:
```
library(devtools)
install_github("myGitHubUserName/mypackage")
```
and there you have it - you've released software.  `Build -> Check Package` is good for testing your package (will tests your examples) and make sure everything looks OK.



```r
devtools::session_info()
```
