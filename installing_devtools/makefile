all: index.html
	
index.html: index.Rmd 
	Rscript -e "rmarkdown::render('index.Rmd')"

clean: 
	rm index.html
