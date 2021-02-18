## ----setup, include=FALSE-----------------------------------------------------
library(dcm2niir)
library(ichseg)
library(dplyr)
library(fslr)
library(extrantsr)
library(TCIApathfinder)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")


## ----get_mods-----------------------------------------------------------------
library(TCIApathfinder)
library(dplyr)
collections = get_collection_names()
collections = collections$collection_names
head(collections)

mods = get_modality_names(body_part = "BREAST")
head(mods$modalities)



## ----get_body_part------------------------------------------------------------
bp = get_body_part_names()
bp$body_parts


## ----bp_get, eval = FALSE-----------------------------------------------------
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


## ----series_info--------------------------------------------------------------
collection = "CPTAC-GBM"
series = get_series_info(
  collection = collection, 
  modality = "CT")
series = series$series
head(series)


## ----download_unzip, cache=FALSE----------------------------------------------
std_head = series %>% 
  filter(grepl("HEAD STD", series_description))
series_instance_uid = std_head$series_instance_uid[1]

download_unzip_series = function(series_instance_uid,
                                 verbose = TRUE) {
  tdir = tempfile()
  dir.create(tdir, recursive = TRUE)
  tfile = tempfile(fileext = ".zip")
  tfile = basename(tfile)
  if (verbose) {
    message("Downloading Series")
  }
  res = save_image_series(
    series_instance_uid = series_instance_uid, 
    out_dir = tdir, 
    out_file_name = tfile)
  if (verbose) {
    message("Unzipping Series")
  }  
  stopifnot(file.exists(res$out_file))
  tdir = tempfile()
  dir.create(tdir, recursive = TRUE)
  res = unzip(zipfile = res$out_file, exdir = tdir)
  L = list(files = res,
           dirs = unique(dirname(normalizePath(res))))
  return(L)
}
# Download and unzip the image series

file_list = download_unzip_series(
  series_instance_uid = series_instance_uid)


## ----dcm2nii, cache = FALSE---------------------------------------------------
library(dcm2niir)
dcm_result = dcm2nii(file_list$dirs)
result = check_dcm2nii(dcm_result)


## ----readnii, cache = FALSE---------------------------------------------------
library(neurobase)
img = readnii(result)
ortho2(img)
range(img)


## -----------------------------------------------------------------------------
img = rescale_img(img, min.val = -1024, max.val = 3071)
ortho2(img)
ortho2(img, window = c(0, 100))


## ----ss-----------------------------------------------------------------------
library(ichseg)
ss = CT_Skull_Strip(img, verbose = FALSE)
ortho2(img, ss > 0, 
       window = c(0, 100),
       col.y = scales::alpha("red", 0.5))


## ----robust_neck--------------------------------------------------------------
collection = "Head-Neck Cetuximab"
series = get_series_info(
  collection = collection, 
  modality = "CT")
series = series$series
whole_body = series %>% 
  filter(grepl("WB", series_description))


## ----download_unzip_robust, cache=FALSE---------------------------------------
file_list = download_unzip_series(
  series_instance_uid = series$series_instance_uid[1])


## ----dcm2nii_robust, cache=FALSE----------------------------------------------
dcm_result = dcm2nii(file_list$dirs, merge_files = TRUE)
result = check_dcm2nii(dcm_result)


## ----readnii2-----------------------------------------------------------------
img = readnii(result)
img = rescale_img(img, min.val = -1024, max.val = 3071)
ortho2(img, window = c(0, 100))


## ----ss2----------------------------------------------------------------------
ss_wb = CT_Skull_Strip(img, verbose = FALSE)
ortho2(ss_wb, window = c(0, 100))


## ----ss_robust----------------------------------------------------------------
ss_wb_robust = CT_Skull_Stripper(img, verbose = FALSE, robust = TRUE)
ortho2(ss_wb_robust, window = c(0, 100))


## ----tabler-------------------------------------------------------------------
library(rvest)
library(dplyr)
x = read_html("https://www.cancerimagingarchive.net/collections/")
tab = html_table(x)[[1]]
head_tab = tab %>% 
  filter(grepl("Head|Brain", Location),
         grepl("CT", `Image Types`), 
         Access == "Public")
brain_tab = tab %>% 
  filter(grepl("Brain", Location),
         grepl("CT", `Image Types`), 
         Access == "Public")
brain_tab


## ----seeded-------------------------------------------------------------------
set.seed(20181203)

patients = get_patient_info(collection = collection)
info = patients$patients
head(info)

