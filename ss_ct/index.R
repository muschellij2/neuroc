## ----setup, include=FALSE------------------------------------------------
library(dcm2niir)
library(ichseg)
library(dplyr)
library(fslr)
library(extrantsr)
library(TCIApathfinder)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")

## ------------------------------------------------------------------------
library(TCIApathfinder)
library(dplyr)
collections = get_collection_names()
collections = collections$collection_names
head(collections)

mods = get_modality_names(body_part = "BREAST")
head(mods$mods)


## ------------------------------------------------------------------------
bp = get_body_part_names()
bp$body_parts

## ----bp_get, eval = FALSE------------------------------------------------
## # could look for any of these
## get_bp = c("BRAIN", "HEAD", "HEADNECK")
## 
## # takes a long time
## res = pbapply::pblapply(collections, function(collection) {
##   x = get_series_info(
##     collection = collection,
##     modality = "CT")
##   x$series
## })

## ------------------------------------------------------------------------
collection = "CPTAC-GBM"
series = get_series_info(
  collection = collection, 
  modality = "CT")
series = series$series
head(series)

## ------------------------------------------------------------------------
std_head = series %>% 
  filter(grepl("HEAD STD", series_description))
series_instance_uid = std_head$series_instance_uid[1]

download_unzip_series = function(series_instance_uid) {
  tdir = tempfile()
  dir.create(tdir, recursive = TRUE)
  tfile = tempfile(fileext = ".zip")
  tfile = basename(tfile)
  res = save_image_series(
    series_instance_uid = series_instance_uid, 
    out_dir = tdir, 
    out_file_name = tfile)
  stopifnot(file.exists(res$out_file))
  tdir = tempfile()
  dir.create(tdir, recursive = TRUE)
  res = unzip(zipfile = res$out_file  , exdir = tdir)
  L = list(files = res,
           dirs = unique(dirname(normalizePath(res))))
  return(L)
}
# Download and unzip the image series

file_list = download_unzip_series(
  series_instance_uid = series_instance_uid)

## ------------------------------------------------------------------------
library(dcm2niir)
dcm_result = dcm2nii(file_list$dirs)
result = check_dcm2nii(dcm_result)

## ------------------------------------------------------------------------
library(neurobase)
img = readnii(result)
ortho2(img)
range(img)

## ------------------------------------------------------------------------
img = rescale_img(img, min.val = -1024, max.val = 3071)
ortho2(img)
ortho2(img, window = c(0, 100))

## ------------------------------------------------------------------------
library(ichseg)
ss = CT_Skull_Strip(img)
ortho2(img, ss > 0, 
       window = c(0, 100),
       col.y = scales::alpha("red", 0.5))

## ----tabler--------------------------------------------------------------
library(rvest)
library(dplyr)
x = read_html("http://www.cancerimagingarchive.net/")
tab = html_table(x)[[1]]
head_tab = tab %>% 
  filter(grepl("Head|Brain", Location),
         grepl("CT", Modalities), 
         Access == "Public")
brain_tab = tab %>% 
  filter(grepl("Brain", Location),
         grepl("CT", Modalities), 
         Access == "Public")
brain_tab

## ------------------------------------------------------------------------
set.seed(20181203)

patients = get_patient_info(collection = collection)
info = patients$patients
head(info)

