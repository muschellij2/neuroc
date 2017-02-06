## ----setup, include=FALSE------------------------------------------------
library(knitr)
knitr::opts_chunk$set(comment = "")

## ------------------------------------------------------------------------
tdir = tempdir()
tfile = file.path(tdir, "example_dwi.zip")
download.file("http://cmic.cs.ucl.ac.uk/camino//uploads/Tutorials/example_dwi.zip",
              destfile = tfile)
files = unzip(zipfile = tfile, exdir = tdir, overwrite = TRUE)

## ----bvecs---------------------------------------------------------------
library(rcamino)
b_data_file = grep("[.]txt$", files, value = TRUE)
scheme_file = camino_pointset2scheme(infile = b_data_file,
                                bvalue = 1e9)

## ----check_img-----------------------------------------------------------
img_fname = grep("4Ddwi_b1000", files, value = TRUE)

## ------------------------------------------------------------------------
float_fname = camino_image2voxel(infile = img_fname, 
                                outputdatatype = "float")

## ------------------------------------------------------------------------
mask_fname = grep("mask", files, value = TRUE)
model_fname = camino_modelfit(
  infile = float_fname,
  scheme = scheme_file,
  mask = mask_fname,
  outputdatatype = "double"
  )

## ------------------------------------------------------------------------
fa_fname = camino_fa(infile = model_fname)

## ------------------------------------------------------------------------
library(neurobase)
fa_img_name = camino_voxel2image(infile = fa_fname, 
                            header = img_fname, 
                            gzip = TRUE, 
                            components = 1)
fa_img = readnii(fa_img_name)

## ------------------------------------------------------------------------
library(magrittr)
fa_img2 = model_fname %>% 
  camino_fa() %>% 
  camino_voxel2image(header = img_fname, gzip = TRUE, components = 1) %>% 
  readnii
all.equal(fa_img2, fa_img2)

## ------------------------------------------------------------------------
ortho2(fa_img)

## ------------------------------------------------------------------------
md_img = model_fname %>% 
  camino_md() %>% 
  camino_voxel2image(header = img_fname, gzip = TRUE, components = 1) %>% 
  readnii
ortho2(md_img)

## ------------------------------------------------------------------------
nifti_dt = camino_dt2nii(
  infile = model_fname, 
  inputmodel = "dt",
  header = img_fname, 
  gzip = TRUE
)
stopifnot(all(file.exists(nifti_dt)))
print(nifti_dt)

## ------------------------------------------------------------------------
dt_imgs = lapply(nifti_dt, readnii, drop_dim = FALSE)

