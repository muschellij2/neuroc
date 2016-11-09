library(yaml)
index = readLines("index.Rmd")
ind = grep("^---", index)[1:2]

yaml = index[seq(ind[1]+1, ind[2]-1)]

yaml = paste(yaml, collapse = "\n")
doc = yaml.load(yaml)
doc$output$html_document$toc = NULL
doc$output$html_document$toc_depth = NULL
doc$output$html_document$toc_float = NULL

yaml = as.yaml(doc)
yaml = strsplit(yaml, "\n")[[1]]

yaml = index[seq(ind[1]+1, ind[2]-1)]

index_notoc = c("---", yaml, "---", index[seq(ind[2]+1, length(index))])

writeLines(text = index_notoc, con = "index_notoc.Rmd")
