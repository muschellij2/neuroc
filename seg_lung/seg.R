library(ANTsRCore)
series_id = "1.3.6.1.4.1.14519.5.2.1.5099.8010.483944973215924538570857470513"
result = "~/Desktop/lung_scan.nii.gz"
aimg = antsImageRead(result)
# aimg[ aimg < -1024 ] = -1024
# aimg[ aimg > 3071 ] = 3071

library(lungct)
lung = segment_lung(aimg)
mask = aimg <= -1024



#tablepress-1_wrapper
