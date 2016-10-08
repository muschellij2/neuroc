LIST = installing_devtools installing_ANTsR 
LIST += nifti_basics
LIST += brain_extraction
LIST += tissue_class_segmentation
LIST += cortical_thickness
LIST += preprocess_mri_within
LIST += fmri_analysis_ANTsR
LIST += fmri_analysis_fslr
LIST += DTI_analysis_fslr

all:
	for fol in $(LIST) ; do \
		pwd && echo $$fol && cp makefile.copy $$fol/makefile && cd $$fol && make && cd ../; \
	done
	Rscript -e "rmarkdown::render('index.Rmd')"
#  

index.html: index.Rmd 
	Rscript -e "rmarkdown::render('index.Rmd')"

clean: 
	rm index.html
