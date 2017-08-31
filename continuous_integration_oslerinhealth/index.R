## ----devtools, include=FALSE---------------------------------------------
library(devtools)

## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
project_name = readLines("project_name")[1]
master_name = switch(
  project_name,
  neuroconductor = "Neuroconductor",
  oslerinhealth = "OSLERinHealth"
)
fname = "continuous_integration"
if (project_name != "neuroconductor") {
  fname = paste0(fname, "_", project_name)
}
website = switch(
  project_name,
  neuroconductor = "https://neuroconductor.org",
  oslerinhealth = "http://oslerinhealth.org"
)

## ---- eval = FALSE-------------------------------------------------------
## devtools::install_github("muschellij2/neuroc.deps")

## ------------------------------------------------------------------------
devtools::session_info()

