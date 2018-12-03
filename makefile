LIST = installing_devtools installing_ANTsR 
LIST += faq
LIST += nifti_basics
LIST += label_image
LIST += brain_extraction
LIST += tissue_class_segmentation
LIST += cortical_thickness
LIST += preprocess_mri_within
LIST += fcp_indi
LIST += fmri_analysis_ANTsR
LIST += fmri_analysis_fslr
LIST += fmri_analysis_spm12r
LIST += DTI_analysis_fslr
LIST += DTI_analysis_rcamino
LIST += DTI_analysis_rcamino_hcp
LIST += ms_lesion
LIST += malf_insula
LIST += neurohcp
LIST += install
LIST += continuous_integration
LIST += getting_ready_for_submission
LIST += install_oslerinhealth
LIST += continuous_integration_oslerinhealth
LIST += r_package_workflow
LIST += windows_wsl
LIST += ss_ct

all:
	for fol in $(LIST) ; do \
		pwd && echo $$fol && cp makefile.copy $$fol/makefile ; \
	done
	Rscript -e "source('notoc.R')"
	Rscript -e "source('link_table.R')"
	Rscript -e "source('make_links.R')"
	cp install/index.Rmd install_oslerinhealth/
	cp continuous_integration/index.Rmd continuous_integration_oslerinhealth/
	for fol in $(LIST) ; do \
		pwd && echo $$fol && cp makefile.copy $$fol/makefile && cd $$fol && make all && cd ../; \
	done
	for fol in $(LIST) ; do \
		cd $$fol && make index_notoc.html && cd ../; \
	done
	Rscript -e "rmarkdown::render('index.Rmd')"
	Rscript -e "rmarkdown::render('index_notoc.Rmd')"
#  

index.html: index.Rmd 
	Rscript -e "rmarkdown::render('index.Rmd')"


clean: 
	rm index.html
