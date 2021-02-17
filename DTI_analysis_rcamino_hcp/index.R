## ----setup, include=FALSE, message=FALSE--------------------------------------
library(knitr)
library(methods)
library(neurobase)
knitr::opts_chunk$set(comment = "")
if (!is.na(Sys.getenv("HCP_AWS_ACCESS_KEY_ID", unset = NA))) {
  Sys.setenv(AWS_ACCESS_KEY_ID = Sys.getenv("HCP_AWS_ACCESS_KEY_ID"))
  Sys.setenv(AWS_SECRET_ACCESS_KEY = Sys.getenv("HCP_AWS_SECRET_ACCESS_KEY"))
}


## ----downloading_data, echo = TRUE--------------------------------------------
library(neurohcp)
hcp_id = "100307"
r = download_hcp_dir(
  paste0("HCP/", hcp_id, "/T1w/Diffusion"), 
  verbose = FALSE)
print(basename(r$output_files))


## ----bvecs--------------------------------------------------------------------
library(rcamino)
camino_set_heap(heap_size = 10000)
outfiles = r$output_files
names(outfiles) = nii.stub(outfiles, bn = TRUE)
scheme_file = camino_fsl2scheme(
  bvecs = outfiles["bvecs"], bvals = outfiles["bvals"],
  bscale = 1)


## ----subsetting---------------------------------------------------------------
camino_ver = packageVersion("rcamino")
if (camino_ver < "0.5.2") {
  source("https://neuroconductor.org/neurocLite.R")
  neuroc_install("rcamino")  
}
sub_data_list = camino_subset_max_bval(
  infile = outfiles["data"],
  schemefile = scheme_file,
  max_bval = 1500,
  verbose = TRUE) 
sub_data = sub_data_list$image
sub_scheme = sub_data_list$scheme


## ----subsetting_rnifti, eval = FALSE------------------------------------------
## nim = RNifti::readNifti(outfiles["data"])
## sub_data = tempfile(fileext = ".nii.gz")
## sub_scheme_res = camino_subset_max_bval_scheme(
##   schemefile = scheme_file, max_bval = 1500,
##   verbose = TRUE)
## nim = nim[,,, sub_scheme$keep_files]
## RNifti::writeNifti(image = nim, file = sub_data)
## sub_scheme = sub_scheme_res$scheme
## rm(list = "nim");
## for (i in 1:10) gc();


## ----model_fit----------------------------------------------------------------
# wdtfit caminoProc/hcp_b5_b1000.Bfloat caminoProc/hcp_b5_b1000.scheme \
# -brainmask 100307/T1w/Diffusion/nodif_brain_mask.nii.gz -outputfile caminoProc/wdt.Bdouble
# 
mod_file = camino_modelfit(
  infile = sub_data, scheme = sub_scheme, 
  mask = outfiles["nodif_brain_mask"], 
  gradadj = outfiles["grad_dev"],
  model = "ldt_wtd")


## ----making_fa----------------------------------------------------------------
# fa -inputfile caminoProc/wdt_dt.nii.gz -outputfile caminoProc/wdt_fa.nii.gz
fa_img = camino_fa_img(
  infile = mod_file,
  header = outfiles["nodif_brain_mask"],
  retimg = FALSE)


## ----fa_read------------------------------------------------------------------
fa_nii = readnii(fa_img)


## ----mask---------------------------------------------------------------------
mask = readnii(outfiles["nodif_brain_mask"])


## ----fa_hist------------------------------------------------------------------
hist(mask_vals(fa_nii, mask = mask), breaks = 1000)


## ----ortho_fa-----------------------------------------------------------------
ortho2(fa_nii)


## ----making_md----------------------------------------------------------------
# md -inputfile caminoProc/wdt_dt.nii.gz -outputfile caminoProc/wdt_md.nii.gz
md_img = camino_md_img(
  infile = mod_file,
  header = outfiles["nodif_brain_mask"],
  retimg = FALSE)


## ----md_read------------------------------------------------------------------
md_nii = readnii(md_img)


## ----md_hist------------------------------------------------------------------
hist(mask_vals(md_nii, mask = mask), breaks = 1000)
md2 = md_nii
md2[ md2 < 0] = 0
hist(mask_vals(md2, mask = mask), breaks = 1000)


## ----ortho_md-----------------------------------------------------------------
ortho2(md_nii)
ortho2(md2)
rb_md = robust_window(md2, probs = c(0, 0.9999))
ortho2(rb_md)


## ----md_hist2-----------------------------------------------------------------
hist(mask_vals(rb_md, mask = mask), breaks = 1000)


## ----nifti_mod, eval = FALSE--------------------------------------------------
## # dt2nii -inputfile caminoProc/wdt.Bdouble -header 100307/T1w/Diffusion/nodif_brain_mask.nii.gz \
## # -outputroot caminoProc/wdt_
## mod_nii = camino_dt2nii(
##   infile = mod_file,
##   header = outfiles["nodif_brain_mask"])


## ----eigen_image, eval = FALSE------------------------------------------------
## # dteig -inputfile caminoProc/wdt.Bdouble -outputfile caminoProc/wdt_eig.Bdouble
## eigen_image = camino_dteig(infile = mod_file)


## ---- eval = FALSE------------------------------------------------------------
## dt_imgs = lapply(mod_nii, readnii, drop_dim = FALSE)


## -----------------------------------------------------------------------------
r_t1_mask = download_hcp_file(
  file.path(
    "HCP", hcp_id, "T1w", 
    "brainmask_fs.nii.gz"), 
  verbose = FALSE
)
print(r_t1_mask)
t1_mask = readnii(r_t1_mask)
r_t1 = download_hcp_file(
  file.path(
    "HCP", hcp_id, "T1w", 
    "T1w_acpc_dc_restore.nii.gz"), 
  verbose = FALSE
)
print(r_t1)
t1 = readnii(r_t1)
brain = mask_img(t1, t1_mask)
hist(mask_vals(brain, t1_mask), breaks = 2000)
rob = robust_window(brain, probs = c(0, 0.9999), mask = t1_mask)
hist(mask_vals(rob, t1_mask), breaks = 2000)


## -----------------------------------------------------------------------------
library(extrantsr)
rigid = registration(
  filename = fa_img,
  template.file = rob,
  correct = FALSE,
  verbose = FALSE,
  typeofTransform = "Rigid")
rigid_trans = rigid$fwdtransforms
aff = R.matlab::readMat(rigid$fwdtransforms)
aff = aff$AffineTransform.float.3.3

double_ortho(rob, rigid$outfile)


## ----mask_rig-----------------------------------------------------------------
rigid_mask = registration(
  filename = outfiles["nodif_brain_mask"],
  template.file = r_t1_mask,
  correct = FALSE,
  typeofTransform = "Rigid",
  affMetric = "meansquares")
rigid_mask_trans = rigid_mask$fwdtransforms

aff_mask = R.matlab::readMat(rigid_mask$fwdtransforms)
aff_mask = aff_mask$AffineTransform.float.3.3

double_ortho(t1_mask, rigid_mask$outfile, NA.x = FALSE)


## -----------------------------------------------------------------------------
library(EveTemplate)
eve_brain_fname = EveTemplate::getEvePath(what = "Brain")
eve_brain = readnii(eve_brain_fname)
nonlin = registration(
  filename = rob,
  template.file = eve_brain_fname,
  correct = FALSE,
  typeofTransform = "SyN")
double_ortho(eve_brain, nonlin$outfile)
nonlin_trans = nonlin$fwdtransforms


## ----composed-----------------------------------------------------------------
composed = c(nonlin_trans, rigid_mask_trans)
fa_eve = ants_apply_transforms(
  fixed = eve_brain_fname,
  moving = fa_img,
  transformlist = composed)
double_ortho(eve_brain, fa_eve)

md_eve = ants_apply_transforms(
  fixed = eve_brain_fname,
  moving = rb_md,
  transformlist = composed)
double_ortho(eve_brain, md_eve)

