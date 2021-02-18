all: index.html index.R 
# index_notoc.html
    
index.html: index.Rmd 
	Rscript -e "rmarkdown::render('index.Rmd')"

#index_notoc.html: index_notoc.Rmd 
#	Rscript -e "rmarkdown::render('index_notoc.Rmd')"

index.R: index.Rmd
	Rscript -e "knitr::purl('index.Rmd')"

clean: 
	rm index.html index.R index_notoc.html
