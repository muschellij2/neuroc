all: 
	cd installing_devtools && make
	cd installing_ANTsR && make
	cd brain_extraction && make
	cd tissue_class_segmentation && make
	cd fmri_analysis_ANTsR && make
	# cd fmri_analysis_fslr && make
