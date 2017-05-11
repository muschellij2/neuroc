## ----setup, include=FALSE------------------------------------------------
library(methods)
knitr::opts_chunk$set(echo = TRUE, cache = FALSE, comment = "")

## ------------------------------------------------------------------------
ver = installed.packages()["neurohcp", "Version"]
if (compareVersion(ver, "0.5") < 0) {
  stop(paste0("Need to update neurohcp, ", 
              "devtools::install_github('muschellij2/neurohcp')")
  )
}

## ----get_data------------------------------------------------------------
library(neurohcp)
fcp_data = download_hcp_file(
    paste0("data/Projects/ABIDE/RawData/", 
        "KKI/0050784/session_1/anat_1/",
        "mprage.nii.gz"),
    bucket = "fcp-indi",
    sign = FALSE)
print(fcp_data)

## ----orig_ortho----------------------------------------------------------
library(neurobase)
std_img = readnii(fcp_data)
ortho2(std_img)

## ----forms---------------------------------------------------------------
library(fslr)
getForms(fcp_data)[c("ssor", "sqor")]

## ----reor----------------------------------------------------------------
reor = rpi_orient(fcp_data)
img = reor$img

## ----bet-----------------------------------------------------------------
library(extrantsr)
bet = fslbet_robust(img, swapdim = FALSE)

## ----plot_bet------------------------------------------------------------
ortho2(robust_window(img), bet)

## ----obet----------------------------------------------------------------
rb = robust_window(img)
bet2 = fslbet_robust(rb, swapdim = FALSE)

## ----obet2---------------------------------------------------------------
ortho2(robust_window(img), bet2)

## ----dropping------------------------------------------------------------
dd = dropEmptyImageDimensions(bet > 0,
    other.imgs = bet)
run_img = dd$other.imgs

## ----orun----------------------------------------------------------------
ortho2(run_img)
ortho2(robust_window(run_img))

## ----get_labs, eval = FALSE----------------------------------------------
## root_template_dir = file.path(
##     "/dcl01/smart/data",
##     "structural",
##     "Templates",
##     "MICCAI-2012-Multi-Atlas-Challenge-Data")
## template_dir = file.path(root_template_dir,
##     "all-images")

## ----labs, eval = FALSE--------------------------------------------------
## library(readr)
## labs = read_csv(file.path(root_template_dir,
##     "MICCAI-Challenge-2012-Label-Information.csv"))
## 
## niis = list.files(
##     path = template_dir,
##     pattern = ".nii.gz",
##     full.names = TRUE)
## bases = nii.stub(niis, bn = TRUE)
## templates = niis[grep("_3$", bases)]
## 
## df = data.frame(
##     template = templates,
##     stringsAsFactors = FALSE)
## df$ss_template = paste0(
##     nii.stub(df$template),
##     "_SS.nii.gz")
## df$label = paste0(
##     nii.stub(df$template),
##     "_glm.nii.gz")
## stopifnot(all(file.exists(unlist(df))))
## 
## indices = labs[grep("sula", tolower(labs$name)),]
## indices = indices$label

## ----reading_data, eval = FALSE------------------------------------------
## library(pbapply)
## lab_list = pblapply(df$label,
##     function(x) {
##     img = fast_readnii(x)
##     niftiarr(img,
##         img %in% indices
##         )
## })
## 
## temp_list = pblapply(df$ss_template, readnii)
## 
## inds = 1:10
## tlist = temp_list[inds]
## llist = lab_list[inds]

## ----running_malf, eval = FALSE------------------------------------------
## res = malf(infile = run_img,
##     template.images = tlist,
##     template.structs = llist,
##     keep_images = FALSE,
##     outfile = "test_malf_mprage_insula.nii.gz")
## 
## wimg = robust_window(run_img)
## png("test_malf_image.png")
## ortho2(wimg, xyz = xyz(res))
## dev.off()
## 
## 
## png("test_malf_image_overlay.png")
## ortho2(wimg, res, xyz = xyz(res),
##     col.y = scales::alpha("red", 0.5))
## dev.off()

