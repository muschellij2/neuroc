## ----setup, include=FALSE-----------------------------------------------------
library(ichseg)
library(dplyr)
library(readr)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")


## -----------------------------------------------------------------------------
library(dataverse)
Sys.setenv("DATAVERSE_SERVER" = "archive.data.jhu.edu")
token = Sys.getenv("JHU_DATAVERSE_API_TOKEN")


## -----------------------------------------------------------------------------
Sys.setenv("DATAVERSE_KEY" = Sys.getenv("JHU_DATAVERSE_API_TOKEN"))


## -----------------------------------------------------------------------------
x = dataverse_search("muschelli AND head ct")
doi = x$global_id
doi


## -----------------------------------------------------------------------------
files = dataverse::get_dataset(doi)
files


## ----dl_file------------------------------------------------------------------
library(readr)
dl_file = function(file, ...) {
  outfile = file.path(tempdir(), basename(file))
  out = get_file(file, ...)
  writeBin(out, outfile)
  return(outfile)
}
fname = grep("Demog", files$files$label, value = TRUE)
demo_file = dl_file(fname, dataset = doi)
demo = readr::read_csv(demo_file)
head(demo)


## ----download_tarball---------------------------------------------------------
library(dplyr)
set.seed(20210217)
run_id = demo %>% 
  filter(dx == "ICH") %>% 
  sample_n(1) %>% 
  pull(id)
fname = paste0(run_id, ".tar.xz")
tarball = dl_file(fname, dataset = doi)
xz_files = untar(tarball, list = TRUE)


## ----extract_data-------------------------------------------------------------
tdir = tempfile()
dir.create(tdir)
untar(tarball, exdir = tdir)
nii_files = list.files(path = tdir, recursive = TRUE, full.names = TRUE)
nii_file = nii_files[!grepl("Mask", nii_files) & grepl(".nii.gz", nii_files)]
mask_file = nii_files[grepl("_Mask.nii.gz", nii_files)]


## ----readnii, cache = FALSE---------------------------------------------------
library(neurobase)
img = readnii(nii_file)
mask = readnii(mask_file)
ortho2(img)
range(img)


## -----------------------------------------------------------------------------
ortho2(img, window = c(0, 100))
masked = window_img(mask_img(img, mask))
ortho2(masked)


## ----seg----------------------------------------------------------------------
library(ichseg)
segmentation = ichseg::predict_deepbleed(nii_file, mask_file)
print(names(segmentation))
print(segmentation)


## ----segplot------------------------------------------------------------------
ortho2(masked, segmentation$native_prediction)


## ----seg_thresh---------------------------------------------------------------
ortho2(masked, segmentation$native_prediction > 0.5, col.y = scales::alpha("red", 0.5))
ortho2(masked, segmentation$native_prediction > 0.9, col.y = scales::alpha("red", 0.5))


## ----func---------------------------------------------------------------------
predict_ich_data = function(id) {
  fname = paste0(id, ".tar.xz")
  tarball = dl_file(fname, dataset = doi)
  xz_files = untar(tarball, list = TRUE)
  tdir = tempfile()
  dir.create(tdir)
  untar(tarball, exdir = tdir)
  nii_files = list.files(path = tdir, recursive = TRUE, full.names = TRUE)
  nii_file = nii_files[!grepl("Mask", nii_files) & grepl(".nii.gz", nii_files)]
  mask_file = nii_files[grepl("_Mask.nii.gz", nii_files)]
  ichseg::predict_deepbleed(nii_file, mask_file)
}

