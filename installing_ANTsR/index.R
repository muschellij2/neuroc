## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ---- eval = FALSE-------------------------------------------------------
## packages = installed.packages()
## packages = packages[, "Package"]
## if (!"devtools" %in% packages) {
##   install.packages("devtools")
## }

## ---- engine = "bash", eval = FALSE--------------------------------------
## sudo apt-get install git # ubuntu/debian
## sudo yum install git # centos/fedora

## ---- eval = FALSE-------------------------------------------------------
## devtools::install_github( "stnava/ITKR" )

## ---- eval = FALSE-------------------------------------------------------
## devtools::install_github( "stnava/ANTsR" )

## ------------------------------------------------------------------------
devtools::session_info()

