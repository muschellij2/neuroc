rm(list = ls())
library(rmarkdown)
library(yaml)
library(tools)
fname = "index.Rmd"

notoc = function(
  fname = "index.Rmd",
  renderIt = FALSE) {
  
  
  index = readLines(fname)
  md_file = sub(".Rmd$", ".md", fname)
  if (file.exists(md_file)) {
      md = readLines(md_file)
    outfile = paste0(file_path_sans_ext(fname),
                     "_notoc.Rmd")
    
    
    ind = grep("^---", index)[1:2]
    
    yaml = index[seq(ind[1] + 1, ind[2] - 1)]
    
    yaml = paste(yaml, collapse = "\n")
    doc = yaml.load(yaml)
    doc$output$html_document$toc = NULL
    doc$output$html_document$toc_depth = NULL
    doc$output$html_document$toc_float = NULL
    doc$output$html_document$keep_md = NULL
    doc$date = NULL
    doc$title = NULL
    
    yaml = as.yaml(doc)
    yaml = strsplit(yaml, "\n")[[1]]
    
    # index[seq(ind[2] + 1, length(index))]
    index_notoc = c("---", yaml, "---", md)
    index_notoc = gsub("index[.]html", "index_notoc.html", index_notoc)
    
    if (file.exists(outfile)) {
      check = readLines(outfile)
      
      if (!identical(check, index_notoc)) {
        writeLines(text = index_notoc, con = outfile)
      } else {
        print("Files are the same, not written!")
      }
    } else {
      writeLines(text = index_notoc, con = outfile)
    }
    
    if (renderIt) {
      rmarkdown::render(input = outfile)
    }
    
    return(file.exists(outfile))
  } else {
    return(FALSE)
  }
}

notoc("index.Rmd", renderIt = FALSE)

all_indices = list.files(pattern = "[.]Rmd$",
                         recursive = TRUE)
all_indices = all_indices[ grep("notoc[.]Rmd$", all_indices, invert = TRUE)]
all_indices = all_indices[ file.exists(gsub(".Rmd$", ".md", all_indices))]
all_indices = setdiff(all_indices, "index.Rmd")
sapply(all_indices, notoc)
