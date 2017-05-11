# MALF of the Insula on an ABIDE patient
John Muschelli  
`r Sys.Date()`  

All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/neuroc/master/malf_insula/index.R).




# Package Version

This tutorial requires the `neurohcp` package (>= 0.5):


```r
ver = installed.packages()["neurohcp", "Version"]
if (compareVersion(ver, "0.5") < 0) {
  stop(paste0("Need to update neurohcp, ", 
              "devtools::install_github('muschellij2/neurohcp')")
  )
}
```
# Data

We will be using the data from the Autism Brain Imaging Data Exchange [ABIDE](http://fcon_1000.projects.nitrc.org/indi/abide/) [@di2014autism].  The data consists of a children with and without autism from the 1000 Functional Connectomes Project and INDI. I chose a child that was young (around 8 years old) so that we can see if this method works for younger brains:


```r
library(neurohcp)
fcp_data = download_hcp_file(
    paste0("data/Projects/ABIDE/RawData/", 
        "KKI/0050784/session_1/anat_1/",
        "mprage.nii.gz"),
    bucket = "fcp-indi",
    sign = FALSE)
```

```

  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |=                                                                |   1%
  |                                                                       
  |=                                                                |   2%
  |                                                                       
  |==                                                               |   2%
  |                                                                       
  |==                                                               |   3%
  |                                                                       
  |==                                                               |   4%
  |                                                                       
  |===                                                              |   4%
  |                                                                       
  |===                                                              |   5%
  |                                                                       
  |====                                                             |   6%
  |                                                                       
  |====                                                             |   7%
  |                                                                       
  |=====                                                            |   7%
  |                                                                       
  |=====                                                            |   8%
  |                                                                       
  |======                                                           |   9%
  |                                                                       
  |======                                                           |  10%
  |                                                                       
  |=======                                                          |  10%
  |                                                                       
  |=======                                                          |  11%
  |                                                                       
  |========                                                         |  12%
  |                                                                       
  |========                                                         |  13%
  |                                                                       
  |=========                                                        |  13%
  |                                                                       
  |=========                                                        |  14%
  |                                                                       
  |==========                                                       |  15%
  |                                                                       
  |==========                                                       |  16%
  |                                                                       
  |===========                                                      |  16%
  |                                                                       
  |===========                                                      |  17%
  |                                                                       
  |===========                                                      |  18%
  |                                                                       
  |============                                                     |  18%
  |                                                                       
  |============                                                     |  19%
  |                                                                       
  |=============                                                    |  20%
  |                                                                       
  |==============                                                   |  21%
  |                                                                       
  |==============                                                   |  22%
  |                                                                       
  |===============                                                  |  22%
  |                                                                       
  |===============                                                  |  23%
  |                                                                       
  |===============                                                  |  24%
  |                                                                       
  |================                                                 |  24%
  |                                                                       
  |================                                                 |  25%
  |                                                                       
  |=================                                                |  26%
  |                                                                       
  |=================                                                |  27%
  |                                                                       
  |==================                                               |  27%
  |                                                                       
  |==================                                               |  28%
  |                                                                       
  |===================                                              |  29%
  |                                                                       
  |===================                                              |  30%
  |                                                                       
  |====================                                             |  30%
  |                                                                       
  |====================                                             |  31%
  |                                                                       
  |=====================                                            |  32%
  |                                                                       
  |=====================                                            |  33%
  |                                                                       
  |======================                                           |  33%
  |                                                                       
  |======================                                           |  34%
  |                                                                       
  |=======================                                          |  35%
  |                                                                       
  |=======================                                          |  36%
  |                                                                       
  |========================                                         |  36%
  |                                                                       
  |========================                                         |  37%
  |                                                                       
  |========================                                         |  38%
  |                                                                       
  |=========================                                        |  38%
  |                                                                       
  |=========================                                        |  39%
  |                                                                       
  |==========================                                       |  40%
  |                                                                       
  |===========================                                      |  41%
  |                                                                       
  |===========================                                      |  42%
  |                                                                       
  |============================                                     |  42%
  |                                                                       
  |============================                                     |  43%
  |                                                                       
  |============================                                     |  44%
  |                                                                       
  |=============================                                    |  44%
  |                                                                       
  |=============================                                    |  45%
  |                                                                       
  |==============================                                   |  46%
  |                                                                       
  |==============================                                   |  47%
  |                                                                       
  |===============================                                  |  47%
  |                                                                       
  |===============================                                  |  48%
  |                                                                       
  |================================                                 |  49%
  |                                                                       
  |================================                                 |  50%
  |                                                                       
  |=================================                                |  50%
  |                                                                       
  |=================================                                |  51%
  |                                                                       
  |==================================                               |  52%
  |                                                                       
  |==================================                               |  53%
  |                                                                       
  |===================================                              |  53%
  |                                                                       
  |===================================                              |  54%
  |                                                                       
  |====================================                             |  55%
  |                                                                       
  |====================================                             |  56%
  |                                                                       
  |=====================================                            |  56%
  |                                                                       
  |=====================================                            |  57%
  |                                                                       
  |=====================================                            |  58%
  |                                                                       
  |======================================                           |  58%
  |                                                                       
  |======================================                           |  59%
  |                                                                       
  |=======================================                          |  60%
  |                                                                       
  |========================================                         |  61%
  |                                                                       
  |========================================                         |  62%
  |                                                                       
  |=========================================                        |  62%
  |                                                                       
  |=========================================                        |  63%
  |                                                                       
  |=========================================                        |  64%
  |                                                                       
  |==========================================                       |  64%
  |                                                                       
  |==========================================                       |  65%
  |                                                                       
  |===========================================                      |  66%
  |                                                                       
  |===========================================                      |  67%
  |                                                                       
  |============================================                     |  67%
  |                                                                       
  |============================================                     |  68%
  |                                                                       
  |=============================================                    |  69%
  |                                                                       
  |=============================================                    |  70%
  |                                                                       
  |==============================================                   |  70%
  |                                                                       
  |==============================================                   |  71%
  |                                                                       
  |===============================================                  |  72%
  |                                                                       
  |===============================================                  |  73%
  |                                                                       
  |================================================                 |  73%
  |                                                                       
  |================================================                 |  74%
  |                                                                       
  |=================================================                |  75%
  |                                                                       
  |=================================================                |  76%
  |                                                                       
  |==================================================               |  76%
  |                                                                       
  |==================================================               |  77%
  |                                                                       
  |==================================================               |  78%
  |                                                                       
  |===================================================              |  78%
  |                                                                       
  |===================================================              |  79%
  |                                                                       
  |====================================================             |  80%
  |                                                                       
  |====================================================             |  81%
  |                                                                       
  |=====================================================            |  81%
  |                                                                       
  |=====================================================            |  82%
  |                                                                       
  |======================================================           |  82%
  |                                                                       
  |======================================================           |  83%
  |                                                                       
  |======================================================           |  84%
  |                                                                       
  |=======================================================          |  84%
  |                                                                       
  |=======================================================          |  85%
  |                                                                       
  |========================================================         |  86%
  |                                                                       
  |========================================================         |  87%
  |                                                                       
  |=========================================================        |  87%
  |                                                                       
  |=========================================================        |  88%
  |                                                                       
  |==========================================================       |  89%
  |                                                                       
  |==========================================================       |  90%
  |                                                                       
  |===========================================================      |  90%
  |                                                                       
  |===========================================================      |  91%
  |                                                                       
  |============================================================     |  92%
  |                                                                       
  |============================================================     |  93%
  |                                                                       
  |=============================================================    |  94%
  |                                                                       
  |==============================================================   |  95%
  |                                                                       
  |==============================================================   |  96%
  |                                                                       
  |===============================================================  |  96%
  |                                                                       
  |===============================================================  |  97%
  |                                                                       
  |================================================================ |  98%
  |                                                                       
  |================================================================ |  99%
  |                                                                       
  |=================================================================| 100%
```

```r
print(fcp_data)
```

```
[1] "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/mprage.nii.gz"
```

Note, you do not need an API key for this data.  We have an MPRAGE for this child downloaded to the disk.

## Visualization


```r
library(neurobase)
```

```
Loading required package: oro.nifti
```

```
oro.nifti 0.7.5
```

```r
std_img = readnii(fcp_data)
ortho2(std_img)
```

![](index_files/figure-html/orig_ortho-1.png)<!-- -->

## Reorientation
Although this image seems to be in RPI orientation, we can check using `getForms`:


```r
library(fslr)
getForms(fcp_data)[c("ssor", "sqor")]
```

```
fslhd "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpUtp76L/mprage.nii.gz" 
```

```
$ssor
[1] "RL" "PA" "IS"

$sqor
[1] "RL" "PA" "IS"
```

This image is indeed in RPI, but we may want to ensure this is the case an use the `rpi_orient` function from fslr so that each image would be in the same orientation:


```r
reor = rpi_orient(fcp_data)
```

```
fslhd "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpUtp76L/mprage.nii.gz" 
```

```
fslorient -getorient "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpUtp76L/mprage.nii.gz"
```

```
fslswapdim "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpUtp76L/mprage.nii.gz"  RL PA IS "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b71b36c025";
```

```r
img = reor$img
```

## Brain Extraction

Here we will use `fslbet_robust` to skull strip the image.  The "robust"

```r
library(extrantsr)
bet = fslbet_robust(img, swapdim = FALSE)
```

```
# Running Bias-Field Correction
```

```
# Registration to template
```

```
# Running Registration of file to template
```

```
# Applying Registration output is
```

```
$warpedmovout
antsImage
  Pixel Type          : float 
  Components Per Pixel: 1 
  Dimensions          : 256x200x256 
  Voxel Spacing       : 0.999999940395355x1x0.999999940395355 
  Origin              : -140.9919 108.048 -138.5018 
  Direction           : 1 0 0 0 -1 0 0 0 1 


$warpedfixout
antsImage
  Pixel Type          : float 
  Components Per Pixel: 1 
  Dimensions          : 182x218x182 
  Voxel Spacing       : 1x1x1 
  Origin              : -90 126 -72 
  Direction           : 1 0 0 0 -1 0 0 0 1 


$fwdtransforms
[1] "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b74ea66ce20GenericAffine.mat"

$invtransforms
[1] "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b74ea66ce20GenericAffine.mat"
```

```
# Applying Transformations to file
```

```
# Applying Transforms to other.files
```

```
# Writing out file
```

```
# Writing out other.files
```

```
# Removing Warping images
```

```
# Reading data back into R
```

```
# Reading in Transformed data
```

```
# Dropping slices not in mask
```

```
# Skull Stripping for COG
```

```
bet2 "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpUtp76L/file34b74d35d160.nii.gz" "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b76e9c24d3" 
```

```
# Skull Stripping with new cog
```

```
bet2 "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpUtp76L/file34b7142229d.nii.gz" "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b77181cf13"  -c 128 97 132
```

```
# Filling Holes 
```


```r
ortho2(robust_window(img), bet)
```

![](index_files/figure-html/plot_bet-1.png)<!-- -->


```r
rb = robust_window(img)
bet2 = fslbet_robust(rb, swapdim = FALSE)
```

```
# Running Bias-Field Correction
```

```
# Registration to template
```

```
# Running Registration of file to template
```

```
# Applying Registration output is
```

```
$warpedmovout
antsImage
  Pixel Type          : float 
  Components Per Pixel: 1 
  Dimensions          : 256x200x256 
  Voxel Spacing       : 0.999999940395355x1x0.999999940395355 
  Origin              : -140.9919 108.048 -138.5018 
  Direction           : 1 0 0 0 -1 0 0 0 1 


$warpedfixout
antsImage
  Pixel Type          : float 
  Components Per Pixel: 1 
  Dimensions          : 182x218x182 
  Voxel Spacing       : 1x1x1 
  Origin              : -90 126 -72 
  Direction           : 1 0 0 0 -1 0 0 0 1 


$fwdtransforms
[1] "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b7128bb55d0GenericAffine.mat"

$invtransforms
[1] "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b7128bb55d0GenericAffine.mat"
```

```
# Applying Transformations to file
```

```
# Applying Transforms to other.files
```

```
# Writing out file
```

```
# Writing out other.files
```

```
# Removing Warping images
```

```
# Reading data back into R
```

```
# Reading in Transformed data
```

```
# Dropping slices not in mask
```

```
# Skull Stripping for COG
```

```
bet2 "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpUtp76L/file34b729c59ca3.nii.gz" "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b7acb4f56" 
```

```
# Skull Stripping with new cog
```

```
bet2 "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpUtp76L/file34b765d47093.nii.gz" "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpUtp76L/file34b73e4600a5"  -c 128 97 131
```

```
# Filling Holes 
```

```r
ortho2(robust_window(img), bet2)
```

![](index_files/figure-html/obet2-1.png)<!-- -->

### Zooming in 

Now that we have only the brain image, we can drop extraneous dimensions.  This dropping is for visualization, but also we may not want these extra dimensions affecting any registration.  


```r
dd = dropEmptyImageDimensions(bet > 0,
    other.imgs = bet)
run_img = dd$other.imgs
```


```r
ortho2(run_img)
```

![](index_files/figure-html/orun-1.png)<!-- -->

```r
ortho2(robust_window(run_img))
```

![](index_files/figure-html/orun-2.png)<!-- -->


## Labeled data


```r
root_template_dir = file.path(
    "/dcl01/smart/data", 
    "structural", 
    "Templates", 
    "MICCAI-2012-Multi-Atlas-Challenge-Data")
template_dir = file.path(root_template_dir,
    "all-images")
```


```r
library(readr)
labs = read_csv(file.path(root_template_dir,
    "MICCAI-Challenge-2012-Label-Information.csv"))

niis = list.files(
    path = template_dir,
    pattern = ".nii.gz", 
    full.names = TRUE)
bases = nii.stub(niis, bn = TRUE)
templates = niis[grep("_3$", bases)]

df = data.frame(
    template = templates,
    stringsAsFactors = FALSE)
df$ss_template = paste0(
    nii.stub(df$template),
    "_SS.nii.gz")
df$label = paste0(
    nii.stub(df$template),
    "_glm.nii.gz")
stopifnot(all(file.exists(unlist(df))))

indices = labs[grep("sula", tolower(labs$name)),]
indices = indices$label
```


```r
library(pbapply)
lab_list = pblapply(df$label,
    function(x) {
    img = fast_readnii(x)
    niftiarr(img, 
        img %in% indices
        )    
})

temp_list = pblapply(df$ss_template, readnii)

inds = 1:10
tlist = temp_list[inds]
llist = lab_list[inds]
```


```r
res = malf(infile = run_img,
    template.images = tlist,
    template.structs = llist,
    keep_images = FALSE,
    outfile = "test_malf_mprage_insula.nii.gz")

wimg = robust_window(run_img)
png("test_malf_image.png")
ortho2(wimg, xyz = xyz(res))
dev.off()


png("test_malf_image_overlay.png")
ortho2(wimg, res, xyz = xyz(res), 
    col.y = scales::alpha("red", 0.5))
dev.off()
```

