# Installing ANTsR
John Muschelli  
`r Sys.Date()`  

<style type="text/css">
div.tocify {
  max-height: 50%;
}
</style>



In this tutorial, we will go through the steps of installing `ANTsR`, including those for `ITKR`.

There are 2 options for installing `ITKR` and `ANTsR`: one is using `devtools` and the other is installing the binaries.  We recommend installing the binary file of `ITKR` and using `devtools` to install `ANTsR`.  

# Option 1: Using Devtools
## Install devtools

You must have `devtools` installed to install from GitHub.


```r
packages = installed.packages()
packages = packages[, "Package"]
if (!"devtools" %in% packages) {
  install.packages("devtools")
}
```

Please refer to [installing devtools](../installing_devtools/index.html) for additional instructions or troubleshooting.

## Mac OSX

You need to install [Command Line Tools](https://developer.apple.com/library/content/technotes/tn2339/_index.html), aka the command line tools for Xcode, if you have not already.  [http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/) is a great tutorial how.

## Windows

Although still untested there is a good [tutorial on running FSL on Windows](http://www.nemotos.net/?p=1481) as well as [ANTsR on Windows through Linux Subsystem](https://github.com/stnava/ANTsR/wiki/Installing-ANTsR-in-Windows-10-(along-with-FSL,-Rstudio,-Freesurfer,-etc)).  


## `cmake` and `git`

[`ANTsR`](https://github.com/stnava/ANTsR) depends on [`ITKR`](https://github.com/stnava/ITKR), which states in the [DESCRIPTION file](https://github.com/stnava/ITKR/blob/master/DESCRIPTION):

```
OS_type: unix
SystemRequirements: cmake, git, clang (recommended)
```

so you must install `git` and `cmake`.  Also, you **must have a Unix-based** system get these programs to work, so Windows users are out of luck.  The continuing discussion will **only** support Linux variants and Mac OSX.



## Setting the PATH

In either Linux or Mac OSX, there is a `PATH` ["environment variable"](https://en.wikipedia.org/wiki/Environment_variable).  This tells your computer which folders to look in when you type in a command.  For example, the `cd` command changes directories and the code (or compiled code) to do that is located in a folder.  When you type `cd`, your computer looks (in order) in the folders specified in the `PATH` variable.  

In a shell (discussed later), you can type
```
which cd
```

and find the executable that you are calling when you actually execute the `cd` command.

## Testing if `cmake` and `git` are installed

Below are some instructions testing whether `git` and `cmake` are installed.  If they are not installed, then there are instructions to install them. 

### Mac OSX

If you are on Mac OSX open up the [Terminal](http://www.macworld.co.uk/feature/mac-software/get-more-out-of-os-x-terminal-3608274/) and type 
```
which cmake
which git
```
and if no paths are returned, then you don't have these installed.  

#### Installing Git
Please go to [https://www.atlassian.com/git/tutorials/install-git/mac-os-x](https://www.atlassian.com/git/tutorials/install-git/mac-os-x) if you do not have `git` installed.  It is a good and comprehensive tutorial on how to install `git` (but you may already have it installed). 

#### Installing CMake
You can download [CMake](https://cmake.org/download/) and you can download either the Binary (recommended) or the Source (more advanced, not covered here - see install instructions from CMake website).  

After downloading the Binary, you will have the CMake application.  If you use the dmg, you can drag and drop the application into the `/Applications` folder.  If you use `bash` (I believe is the default), then open the Terminal, type `vi ~/.bash_profile`.  This will open an editor (`vi`) and type the letter `i`, go to the bottom of the document, and copy and paste
```
export PATH=$PATH:/Applications/CMake.app/Contents/bin
```
to the bottom.  To exit type `ESC+:+wq`.  The `ESC` escapes anything you were doing (like inserting text), the colon is telling `vi` you're in "Colon mode, the `w` means write the file, and `q` means quit.  If you edited a file and don't want to save changes, use `:q!` (quitting and not saving/writing).  


### Linux 

You open up the [Terminal](http://www.howtogeek.com/howto/22283/four-ways-to-get-instant-access-to-a-terminal-in-linux/) and type :
```
which cmake
which git
```
and if no paths are returned, then you don't have these installed.  

#### Installing git

Depending on the variant of Linux you are on, the following commands should work:


```bash
sudo apt-get install git # ubuntu/debian
sudo yum install git # centos/fedora
```

#### Installing cmake

[http://askubuntu.com/questions/610291/how-to-install-cmake-3-2-on-ubuntu-14-04](http://askubuntu.com/questions/610291/how-to-install-cmake-3-2-on-ubuntu-14-04) is a good discussion on how to install `cmake` on Ubuntu.  [https://help.directadmin.com/item.php?id=494](https://help.directadmin.com/item.php?id=494) is a good discussion on how to install `cmake` on Centos (hint `sudo yum install cmake`). 



## Installing ITKR

**You must install `ITKR` and `ANTsR` from R from a Terminal NOT from a GUI (RStudio/R application).**


After `devtools` is installed, you can update `ITKR`:

```r
devtools::install_github( "stnava/ITKR" )
```

This will take a lot of time to compile and such.



## Installing ANTsR

**You must install `ITKR` and `ANTsR` from R from a Terminal NOT from a GUI (RStudio/R application).**

If `ITKR` did not install, stop.  Stop here.  `ANTsR` cannot work without `ITKR`.  If you think `ITKR` has a configuration problem and **NOT** a problem with your setup, you should [open an issue](https://github.com/stnava/ITKR/issues) and see if the authors would be able to fix it.  Make sure you try the same steps on another machine (or virtual machine) before saying that something is "broken".  

Again, we can install `ANTsR` using `devtools:


```r
devtools::install_github( "stnava/ANTsR" )
```

This also will take a lot of time to compile.

## Updating ANTsR

`ANTsR` takes a long time to compile and `ITKR` takes even longer.   If you want to re-install or update `ANTsR` from GitHub, but not update any of the dependencies (including `ITKR`), then you should run: 
```r
devtools::install_github("stnava/ANTsR", upgrade_dependencies = FALSE)
```


# Option 2: Installing Binaries

If you go to the [Release Page for ANTsR](https://github.com/stnava/ANTsR/releases) they have pre-built binary releases for different systems.  If not specified, a `.tgz` should be the binary for the Mac OSX version and the `.tar.gz` should be that for a PC/Linux.  You should check to see when the last release was made as some of these may be largely outdated, may not have the latest bug fixes, and may not be versioned corresponding to some common rules.

# Troubleshooting errors

If you see the following error when installing ITKR:
```
./configure: line 26: cmake: command not found
```
guess what?  `cmake` cannot be found.  You either need to repeat the steps above or try to install ITKR using a Terminal (by calling `R`) instead of RStudio or the R application.  This is due to some environment variables (not `PATH` though) not being available to those programs.  Also, make sure you put `export` before `PATH`, and make sure `PATH` is not defined somewhere lower in the `~/.bash_profile` and overwrites your changes.

You can see all of `PATH` by typing in the Terminal:
```
echo ${PATH}
```

## RGL

One of the packages `ANTsR` suggests is `rgl`.  For Mac OSX, this should be installed with the package if not already installed, which usually works OK.  On some Linux variants like Ubuntu, the installation may fail.  

If you have errors installing `rgl`, then according to [a StackOverflow post](http://stackoverflow.com/questions/31820865/error-in-installing-rgl-package), you can install using the following command:
```
sudo apt-get install r-cran-rgl
```


# Session Info


```r
devtools::session_info()
```

```
## Session info --------------------------------------------------------------
```

```
##  setting  value                       
##  version  R version 3.3.1 (2016-06-21)
##  system   x86_64, darwin13.4.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  tz       America/New_York            
##  date     2016-11-09
```

```
## Packages ------------------------------------------------------------------
```

```
##  package    * version date       source                            
##  assertthat   0.1     2013-12-06 CRAN (R 3.2.0)                    
##  colorout   * 1.1-0   2015-04-20 Github (jalvesaq/colorout@1539f1f)
##  devtools     1.12.0  2016-06-24 CRAN (R 3.3.0)                    
##  digest       0.6.10  2016-08-02 cran (@0.6.10)                    
##  evaluate     0.9     2016-04-29 CRAN (R 3.2.5)                    
##  formatR      1.4     2016-05-09 CRAN (R 3.2.5)                    
##  htmltools    0.3.6   2016-09-26 Github (rstudio/htmltools@6996430)
##  knitr        1.14    2016-08-13 CRAN (R 3.3.0)                    
##  magrittr     1.5     2014-11-22 CRAN (R 3.2.0)                    
##  memoise      1.0.0   2016-01-29 CRAN (R 3.2.3)                    
##  Rcpp         0.12.7  2016-09-05 cran (@0.12.7)                    
##  rmarkdown    1.1     2016-10-16 CRAN (R 3.3.1)                    
##  stringi      1.1.1   2016-05-27 CRAN (R 3.3.0)                    
##  stringr      1.1.0   2016-08-19 cran (@1.1.0)                     
##  tibble       1.2     2016-08-26 CRAN (R 3.3.0)                    
##  withr        1.0.2   2016-06-20 CRAN (R 3.3.0)                    
##  yaml         2.1.13  2014-06-12 CRAN (R 3.2.0)
```
