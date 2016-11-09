LIST = installing_devtools installing_ANTsR 
LIST += faq
LIST += nifti_basics
LIST += brain_extraction
LIST += tissue_class_segmentation
LIST += cortical_thickness
LIST += preprocess_mri_within
LIST += fmri_analysis_ANTsR
LIST += fmri_analysis_fslr
LIST += DTI_analysis_fslr
LIST += ms_lesion

all:
	for fol in $(LIST) ; do \
		pwd && echo $$fol && cp makefile.copy $$fol/makefile && cd $$fol && make && cd ../; \
	done
	Rscript -e "rmarkdown::render('index.Rmd')"
	Rscript -e "source('notoc.R')"
	Rscript -e "rmarkdown::render('index_notoc.Rmd')"
#  

index.html: index.Rmd 
	Rscript -e "rmarkdown::render('index.Rmd')"


clean: 
	rm index.html
