## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ---- eval = FALSE-------------------------------------------------------
## ## try https:// if http:// URLs are supported
## source("http://neuroconductor.org/neurocLite.R")
## neuro_install("PACKAGE")

## ----eval = FALSE--------------------------------------------------------
## source("http://neuroconductor.org/neurocLite.R")
## neuro_install(c("fslr", "hcp"))

## ----eval = FALSE--------------------------------------------------------
## source("http://neuroconductor.org/neurocLite.R")
## neurocLite(c("fslr", "hcp"))

## ----eval = FALSE--------------------------------------------------------
## source("http://neuroconductor.org/neurocLite.R")
## neuro_install("neurocInstall")

## ---- eval = FALSE-------------------------------------------------------
## neurocLite(c("fslr", "hcp"), upgrade_dependencies = FALSE)

