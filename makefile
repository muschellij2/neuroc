all: 
	cd installing_devtools && make
	cd installing_ANTsR && make
	cd brain_extraction && make
	cd tissue_class_segmentation && make
	cd fmri_analysis_ANTsR && make
	cd fmri_analysis_fslr && make
	cd fmri_analysis_fslr && make
	cd preprocess_mri_within && make
	Rscript -e "rmarkdown::render('index.Rmd')"
	
index.html: index.Rmd 
	Rscript -e "rmarkdown::render('index.Rmd')"

clean: 
	rm index.html
