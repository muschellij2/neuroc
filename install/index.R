## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ---- eval = FALSE-------------------------------------------------------
## ## try https:// if http:// URLs are supported
## source("https://neuroconductor.org/neurocLite.R")
## neuro_install("PACKAGE")

## ----eval = FALSE--------------------------------------------------------
## source("https://neuroconductor.org/neurocLite.R")
## neuro_install(c("fslr", "hcp"))

## ----eval = FALSE--------------------------------------------------------
## source("https://neuroconductor.org/neurocLite.R")
## neurocLite(c("fslr", "hcp"))

## ----eval = FALSE--------------------------------------------------------
## source("https://neuroconductor.org/neurocLite.R")
## neuro_install("neurocInstall")

## ---- eval = FALSE-------------------------------------------------------
## neurocLite(c("fslr", "hcp"), upgrade_dependencies = FALSE)

## ---- cache = FALSE------------------------------------------------------
devtools::session_info()

