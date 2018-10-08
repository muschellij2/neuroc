---
title: "Installing on the Windows Subsystem for Linux (WSL)"
author: "John Muschelli"
date: "2018-10-08"
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



All code for this document is located [here](https://github.com/muschellij2/neuroc/blob/master/windows_wsl/index.Rmd).

Here we will discuss hwo to get FSL (and other Linux only applications) onto a Windows machine using the [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10).  All of these instructions require Windows 10 or higher.  Some of this content was adapted from http://www.nemotos.net/?p=1481.


# Install Linux Subsystem

Information below can be found here (https://docs.microsoft.com/en-us/windows/wsl/install-win10)

1.  Enable **"Windows Subsystem for Linux"** feature using one of the options here
  - Option 1 (easy): Check the appropriate box within "Turn Windows features on or off" dialog box. (Open Settings -> Search “programs” -> Select "Turn Windows features on or off")
Step 1b: You will need to restart your computer, as prompted, after this feature is enabled. 
  - Option 1 (faster but harder): Use Command-Line/PowerShell by pasting in the code below
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux 
```
2. Download and install your preferred Linux distribution from the Windows Store – Ubuntu is the recommended distribution.  There are other options to download from Command-Line/Script or download and manually Unpack/Install.

3. Open Ubuntu.  Here we will set up [NeuroDebian](http://neuro.debian.net/) using `bash`, which houses a ton of neuroimaging software:

```bash 
sudo apt-get update -qq -y
sudo apt-get install -y wget git
OS_DISTRIBUTION=$(lsb_release -cs)
wget -O- http://neuro.debian.net/lists/${OS_DISTRIBUTION}.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
sudo apt-get update
```

4.  Install FSL:

```bash
sudo apt-get install fsl
```

5.  Run these following commands:

```bash
echo ". /etc/fsl/fsl.sh" >> ~/.bashrc
echo "export DISPLAY=localhost:0.0" >> ~/.bashrc
```

This will set up the FSL environment whenever you have `bash` opened up in a new window.  Also, this will allow FSL to open displays on the machine.


# Getting Windows to Pop up


1.  In Linux, Install `x11` apps (https://virtualizationreview.com/articles/2017/02/08/graphical-programs-on-windows-subsystem-on-linux.aspx):
```bash
sudo apt-get install x11-apps
```
2.  Start [Xming](https://sourceforge.net/projects/xming/) (or other x11 app) on the **Windows** side.


# Setting up `R` 

1. Install `R` with OpenBLAS capabilities:
```bash
sudo apt-get install libopenblas-base r-base
```

2.  Install RStudio Server.  Check https://www.rstudio.com/products/rstudio/download-server/ to make sure this is the most up-to-date version:

```bash
export RSTUDIO_VERSION=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver)
echo "VERSION ${RSTUDIO_VERSION}"
sudo wget -q http://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb
sudo gdebi --non-interactive rstudio-server-${RSTUDIO_VERSION}-amd64.deb
sudo rm rstudio-server-*-amd64.deb 
```

3.  On the **Windows** side, navigate on a browser (e.g. Chrome) to `https://localhost:8787`, which should give you a login screen. Use the login information for the Ubuntu machine to use RStudio (with the Linux backend) on the Windows machine!


# Installing Packages in `R`

1.  Install the requirements for the dependencies for `devtools`:

```bash 
sudo apt-get update -qq -y
sudo apt-get install -y libgit2-dev 
sudo apt-get install -y libcurl4-openssl-dev libssl-dev
sudo apt-get install -y zlib1g-dev libssh2-1-dev libpq-dev libxml2-dev 
sudo apt-get install -y libhdf5
```

2. In the RStudio server or `R`.  Install `devtools` and `fslr`:
```r
install.packages("devtools", repos = "https://cran.rstudio.com/")
source("https://neuroconductor.org/neurocLite.R") 
neuro_install("fslr")
```

Check this installation by trying to run some help file, such as:
```r
fslr::fast.help()
```

2. In the RStudio server or `R`.  Install `devtools` and `fslr`:
```r
neuro_install("extrantsr")
```


# Session Info


```r
devtools::session_info()
```
