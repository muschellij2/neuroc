## ----setup, include=FALSE, message=FALSE---------------------------------
library(knitr)
library(methods)
library(neurobase)
knitr::opts_chunk$set(comment = "")

## ----downloading_data, echo = TRUE---------------------------------------
library(neurohcp)
hcp_id = "100307"
r = download_hcp_dir(paste0("HCP/", hcp_id, "/T1w/Diffusion"))
print(basename(r$output_files))

## ----bvecs---------------------------------------------------------------
library(rcamino)
camino_set_heap(heap_size = 10000)
outfiles = r$output_files
names(outfiles) = nii.stub(outfiles, bn = TRUE)
scheme_file = camino_fsl2scheme(
  bvecs = outfiles["bvecs"], bvals = outfiles["bvals"],
  bscale = 1)

## ----subsetting----------------------------------------------------------
camino_ver = packageVersion("rcamino")
if (camino_ver < "0.5.2") {
  devtools::install_github("muschellij2/rcamino")
}
sub_data_list = camino_subset_max_bval(
  infile = outfiles["data"],
  schemefile = scheme_file,
  max_bval = 1500,
  verbose = TRUE) 
sub_data = sub_data_list$image
sub_scheme = sub_data_list$scheme

## ----model_fit-----------------------------------------------------------
# wdtfit caminoProc/hcp_b5_b1000.Bfloat caminoProc/hcp_b5_b1000.scheme \
# -brainmask 100307/T1w/Diffusion/nodif_brain_mask.nii.gz -outputfile caminoProc/wdt.Bdouble
# 
mod_file = camino_modelfit(
  infile = sub_data, scheme = sub_scheme, 
  mask = outfiles["nodif_brain_mask"], 
  model = "ldt_wtd")

## ----making_fa-----------------------------------------------------------
# fa -inputfile caminoProc/wdt_dt.nii.gz -outputfile caminoProc/wdt_fa.nii.gz
fa_img = camino_fa_img(
  infile = mod_file,
  header = outfiles["nodif_brain_mask"],
  retimg = FALSE)

## ----fa_read-------------------------------------------------------------
fa_nii = readnii(fa_img)

## ----mask----------------------------------------------------------------
mask = readnii(outfiles["nodif_brain_mask"])

## ----fa_hist-------------------------------------------------------------
hist(mask_vals(fa_nii, mask = mask), breaks = 1000)

## ----ortho_fa------------------------------------------------------------
ortho2(fa_nii)

## ----making_md-----------------------------------------------------------
# md -inputfile caminoProc/wdt_dt.nii.gz -outputfile caminoProc/wdt_md.nii.gz
md_img = camino_md_img(
  infile = mod_file,
  header = outfiles["nodif_brain_mask"],
  retimg = FALSE)

## ----md_read-------------------------------------------------------------
md_nii = readnii(md_img)

## ----md_hist-------------------------------------------------------------
hist(mask_vals(md_nii, mask = mask), breaks = 1000)
md2 = md_nii
md2[ md2 < 0] = 0
hist(mask_vals(md2, mask = mask), breaks = 1000)

## ----ortho_md------------------------------------------------------------
ortho2(md_nii)
ortho2(md2)
rb = robust_window(md2, probs = c(0, 0.9999))
ortho2(rb)

## ----md_hist2------------------------------------------------------------
hist(mask_vals(md2, mask = mask), breaks = 1000)

## ----nifti_mod, eval = FALSE---------------------------------------------
## # dt2nii -inputfile caminoProc/wdt.Bdouble -header 100307/T1w/Diffusion/nodif_brain_mask.nii.gz \
## # -outputroot caminoProc/wdt_
## mod_nii = camino_dt2nii(
##   infile = mod_file,
##   header = outfiles["nodif_brain_mask"])

## ----eigen_image, eval = FALSE-------------------------------------------
## # dteig -inputfile caminoProc/wdt.Bdouble -outputfile caminoProc/wdt_eig.Bdouble
## eigen_image = camino_dteig(infile = mod_file)

## ---- eval = FALSE-------------------------------------------------------
## dt_imgs = lapply(mod_nii, readnii, drop_dim = FALSE)

