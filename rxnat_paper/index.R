## --- setup, include=FALSE
library(Rxnat)
library(dplyr)
library(fslr)
library(extrantsr)
library(malf.templates)
library(scales)
library(WhiteStripe)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")

### --- eval = FALSE
## packages = installed.packages()
## packages = packages[, "Package"]
## if (!"Rxnat" %in% packages) {
##  source("https://neuroconductor.org/neurocLite.R")
##  neuroc_install("Rxnat")    
## }

## -- data, message = FALSE, warning = FALSE, cache = TRUE
library(Rxnat)
nitrc <- xnat_connect("https://nitrc.org/ir", xnat_name="NITRC")
# Download the subject T1 weighted image
file_path <- nitrc$download_dir(
  experiment_ID = 'NITRC_IR_E10464',
  scan_type = "T1",
  extract = TRUE)
t1_fname <- file_path[1]
t1 <- readrpi(t1_fname)
ortho2(t1, add.orient = TRUE)

# Remove neck and drop empty dimensions
## --- remove-neck, message = FALSE, warning = FALSE, cache = TRUE
noneck = remove_neck(file_path,
                     template.file = fslr::mni_fname(brain = TRUE, mm = 1),
                     template.mask = fslr::mni_fname(mm = 1, brain = TRUE, mask = TRUE),
                     verbose = FALSE
)
red = dropEmptyImageDimensions(noneck)
red <- readrpi(red)
ortho2(red, add.orient = TRUE)

# Inhomogeneity correction
## --- correction, message = FALSE, warning = FALSE, cache = TRUE
t1_n4 = bias_correct(red,
                     correction = "N4",
                     outfile = tempfile(fileext = ".nii.gz"), retimg = FALSE
)
t1_n4 <- readrpi(t1_n4)

# Malf registration
## --- malf, message = FALSE, warning = FALSE, cache = TRUE
timgs = mass_images(n_templates = 35)
ss = malf(infile = t1_n4,
          template.images = timgs$images,
          template.structs = timgs$masks,
          keep_images = FALSE,
          verbose = FALSE)

# Perform skull stripping
## --- ss, message = FALSE, warning = FALSE, cache = TRUE
proc_outfile <- paste0("T1_Processed.nii.gz")
proc_outfile <- file.path(tempdir(),proc_outfile)
skull_ss <- preprocess_mri_within(
  files = t1_n4,
  outfiles = proc_outfile,
  correction = "N4",
  maskfile = ss,
  correct_after_mask = FALSE)
t1_ss <- readrpi(proc_outfile)
ortho2(red,
       t1_ss,
       col.y=alpha("red", 0.3),
       add.orient = TRUE)

# Perform WhiteStripe intensity normalization
## --- ws, message = FALSE, warning = FALSE, cache = TRUE
ind = whitestripe(img = t1_ss, type = "T1", stripped = TRUE)$whitestripe.ind
ws_t1 = whitestripe_norm(t1_ss, ind)

# Perform segmentation
## --- tcs, message = FALSE, warning = FALSE, cache = TRUE
ss_tcs = fslr::fast_nobias(ws_t1,
                           verbose = TRUE)
double_ortho(ws_t1,
             ss_tcs,
             add.orient=TRUE)


# Session Info
## --- cache = FALSE}
devtools::session_info()
