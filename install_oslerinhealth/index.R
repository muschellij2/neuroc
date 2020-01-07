## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
project_name = readLines("project_name")[1]
master_name = switch(
  project_name,
  neuroconductor = "Neuroconductor",
  oslerinhealth = "OSLERinHealth"
)
fname = "install"
if (project_name != "neuroconductor") {
  fname = paste0(fname, "_", project_name)
}
website = switch(
  project_name,
  neuroconductor = "https://neuroconductor.org",
  oslerinhealth = "http://oslerinhealth.org"
)
lite_file = switch(
  project_name,
  neuroconductor = "https://neuroconductor.org/neurocLite.R",
  oslerinhealth = "http://oslerinhealth.org/oslerLite.R"
)
installer = switch(
  project_name,
  neuroconductor = "neuro_install",
  oslerinhealth = "osler_install")
lite_installer = switch(
  project_name,
  neuroconductor = "neurocLite",
  oslerinhealth = "oslerLite")
install_pack = switch(
  project_name,
  neuroconductor = "neurocInstall",
  oslerinhealth = "oslerInstall")
packs = switch(
  project_name,
  neuroconductor = c("fslr", "neurohcp"),
  oslerinhealth = c("baker", "spotgear")
)
dpacks = paste0('c("', packs[1], '", "', packs[2], '")')


## ---- cache = FALSE-----------------------------------------------------------
devtools::session_info()

