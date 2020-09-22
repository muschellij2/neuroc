## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")


## ----knit-setup, echo=FALSE, results='hide', eval=TRUE, cache = FALSE, warning = FALSE, message = FALSE----
library(spm12r)
library(methods)


## ----makefiles----------------------------------------------------------------
library(kirby21.t1)
library(kirby21.fmri)
stopifnot(download_fmri_data())
stopifnot(download_t1_data())
functional = get_fmri_filenames(ids = 113, visit = 1)
anatomical = get_t1_filenames(ids = 113, visit = 1)
files = c(anatomical = anatomical,
          functional = functional)
files


## -----------------------------------------------------------------------------
library(neurobase)
tr = 2 # seconds
DROP = 10 # 20 seconds for stabilization

fmri = readnii(files["functional"])

times = (DROP + 1):ntim(fmri)
run_fmri = copyNIfTIHeader(fmri, fmri[,,,times], drop = TRUE)


## ---- echo = FALSE------------------------------------------------------------
rm(list = "fmri"); gc(); gc();


## ----nb_version, echo = FALSE, results="hide"---------------------------------
library(neurobase)
ip = installed.packages()
ver = ip["neurobase", "Version"]
ver = compareVersion(ver, "1.13")
if (ver < 0) {
  remap_filename = function(
    x, 
    prefix = "", 
    suffix = "") {
    
    ext = parse_img_ext(x)
    ext = paste0(".", ext)
    tx = tolower(x)
    if (grepl("gz$", tx)) {
      ext = paste0(ext, ".gz")
    }
    dn = dirname(x)
    stub = nii.stub(x, bn = TRUE)
    
    file.path(
      dn,
      paste0(
        prefix, 
        stub,
        suffix,
        ext)
    )
  }
}


## ----have_matlab--------------------------------------------------------------
library(matlabr)
have_matlab()


## ----realign------------------------------------------------------------------
library(spm12r)
####################################
# Realignment
####################################
if (have_matlab()) {
  realigned = spm12_realign( 
	filename = run_fmri, 
	register_to = "mean",
	reslice = "mean",
	clean = FALSE
	)
  print(realigned)
}


## ----rp_file------------------------------------------------------------------
####################################
# Read in Motion data
####################################
if (have_matlab()) {
  rpfile = realigned[['rp']]
  rp = read.table(file = rpfile, header = FALSE)
  colnames(rp) = c("x", "y", "z", 
  	"roll", "pitch", "yaw")
  rp = as.matrix(rp)
  print(head(rp))
  print(dim(rp))
}


## ----slice_time---------------------------------------------------------------
####################################
# Slice Timing Correction
####################################
nslices = oro.nifti::nsli(run_fmri)
slice_order = 1:nslices
ref_slice = slice_order[median(seq(nslices))]
ta = tr - tr/nslices
n_time_points = ntim(run_fmri)
if (have_matlab()) {
  aimg = spm12_slice_timing(
  	filename = realigned[['outfiles']],
  	nslices = nslices,
  	tr = tr, 
  	slice_order = slice_order,
  	ta = ta, 
  	ref_slice = ref_slice,
  	prefix = "a", 
  	clean = FALSE, 
  	retimg = FALSE)
  print(aimg)
  mean_img = realigned[["mean"]]
  mean_nifti = readnii(mean_img)
}


## ----acpc---------------------------------------------------------------------
if (have_matlab()) {
  acpc_reorient(
    infiles = c(mean_img, aimg),
    modality = "T1")
}


## ----direct_norm--------------------------------------------------------------
if (have_matlab()) {
  bbox = matrix(
  		c(-90, -126, -72, 
  		90, 90, 108), 
  		nrow = 2, byrow = TRUE)
  print(bbox)
  direct_norm = spm12_normalize(
  	filename = mean_img,
  	other.files = c(mean_img, aimg),
  	bounding_box = bbox,
  	clean = FALSE
  	)
  print(direct_norm)
  dnorm_files = direct_norm$outfiles
  dnorm_mean_img = readnii(dnorm_files[1])
}


## ----coreg--------------------------------------------------------------------
if (have_matlab()) {
  anatomical = files["anatomical"]
  anat_img = checknii(anatomical)
  print(anat_img)
  acpc_reorient(
    infiles = anat_img,
    modality = "T1")

  coreg = spm12_coregister(
  	fixed = mean_img,
  	moving = anat_img,
  	prefix = "r")
  
  coreg_anat = coreg$outfile
  coreg_img = readnii(coreg_anat)
  double_ortho(coreg_img, mean_nifti)
}


## ----seg----------------------------------------------------------------------
if (have_matlab()) {
  seg_res = spm12_segment(
  	filename = coreg_anat,
  	set_origin = FALSE,
  	retimg = FALSE)
  print(seg_res)
}


## ----segs_to_hard-------------------------------------------------------------
alpha = function(col, alpha = 1) {
  cols = t(col2rgb(col, alpha = FALSE)/255)
  rgb(cols, alpha = alpha)
} 
if (have_matlab()) {
  seg_files = check_nifti(seg_res$outfiles)
  hard_seg = spm_probs_to_seg(seg_files)
  hard_seg[ hard_seg > 3] = 0
  
  ortho2(coreg_img, hard_seg, 
         col.y = alpha(c("red", "green", "blue"), 0.5))
}


## ----norm_write---------------------------------------------------------------
bbox = matrix(
  c(-90, -126, -72, 
    90, 90, 108), 
  nrow = 2, byrow = TRUE)
if (have_matlab()) {
  norm = spm12_normalize_write(
  	deformation = seg_res$deformation,
  	other.files = c(coreg_anat, mean_img, aimg),
  	bounding_box = bbox,
  	retimg = FALSE, 
  	clean = FALSE)
  print(norm)
  norm_data = norm$outfiles
  names(norm_data) = c("anat", "mean", "fmri")
  norm_mean_img = readnii(norm_data["mean"])
  norm_anat_img = readnii(norm_data["anat"])
}


## ----check_norm---------------------------------------------------------------
if (have_matlab()) {
  template_path = file.path(spm_dir(), 
                            "canonical", "avg152T1.nii")

  template = readnii(template_path)
  
  dnorm_mask = dnorm_mean_img > quantile(
    dnorm_mean_img[dnorm_mean_img > 0], 
    probs = 0.6)
  norm_mask = norm_mean_img > quantile(
    norm_mean_img[norm_mean_img > 0], 
    probs = 0.6)  
  
  double_ortho(template, norm_anat_img)
  double_ortho(template, norm_mean_img)
  double_ortho(norm_mean_img, norm_anat_img)
  ortho2(template, norm_mask, col.y = alpha("red", 0.5))

  double_ortho(template, dnorm_mean_img)
  ortho2(template, dnorm_mask, col.y = alpha("red", 0.5))
  double_ortho(norm_mean_img, dnorm_mean_img)
}


## ----smooth-------------------------------------------------------------------
if (have_matlab()) {
  smoothed = spm12_smooth(
  	filename = norm_data["fmri"],
  	fwhm = 8,
  	prefix = "s",
  	retimg = FALSE
  	)
  smoothed_data = smoothed$outfiles
}


## ----smooth_mean--------------------------------------------------------------
if (have_matlab()) {
  smoothed_mean = spm12_smooth(
  	filename = norm_data["mean"],
  	prefix = "s",
  	retimg = FALSE
  	)  
  smoothed_mean_data = smoothed_mean$outfiles
}


## ----plot_smoothed_mean-------------------------------------------------------
if (have_matlab()) {
  smooth_mean_img = readnii(smoothed_mean_data)
  ortho2(smooth_mean_img)
}


## -----------------------------------------------------------------------------
bib = '@article{ashburner2005unified,
  title={Unified segmentation},
  author={Ashburner, John and Friston, Karl J},
  journal={Neuroimage},
  volume={26},
  number={3},
  pages={839--851},
  year={2005},
  publisher={Elsevier}
}'

