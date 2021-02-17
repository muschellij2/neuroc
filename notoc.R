rm(list = ls())
library(rmarkdown)
library(yaml)
library(tools)
library(stringr)
fname = "index.Rmd"
all_indices = list.files(pattern = "[.]Rmd$",
                         recursive = TRUE)
all_indices = all_indices[ grep("notoc[.]Rmd$", all_indices, invert = TRUE)]
all_indices = all_indices[ file.exists(gsub(".Rmd$", ".md", all_indices))]
all_indices = setdiff(all_indices, "index.Rmd")
fname = all_indices[1]
all_html = sub(".Rmd", ".html", all_indices)
all_notoc = sub("[.]Rmd$", "_notoc.html", all_indices)
subber = TRUE

notoc = function(fname = "index.Rmd") {
  print(fname)
  html = sub(".Rmd", ".html", fname)
  outfile = sub("[.]Rmd$", "_notoc.html", fname)
  fe = file.exists(html, outfile)
  if (all(fe)) {
    if (file.mtime(html) < file.mtime(outfile)) {
      return(TRUE)
    }
  }
  tfile = tempfile(fileext = ".html")
  file.copy(html, tfile)
  on.exit(file.copy(tfile, html, overwrite = TRUE,
                    copy.date = TRUE), add = TRUE)
  try({
  rmarkdown::render(fname, 
                    envir = new.env(),
                    output_format = html_document())
  })
  file.rename(html, outfile)
}
sapply(all_indices, notoc)

# 
# notoc = function(
#   fname = "index.Rmd",
#   renderIt = FALSE,
#   subber = TRUE,
#   addR = TRUE) {
#   
#   
#   index = readLines(fname)
#   md_file = sub(".Rmd$", ".md", fname)
#   if (file.exists(md_file)) {
#     md = readLines(md_file)
#     
#     # HACK
#     # using date to limit the header stuff
#     # remove titles and such
#     date_ind = grep("^`r Sys", md)
#     if (length(date_ind) > 0) {
#       md = md[ seq(date_ind + 1, length(md)) ]
#     }
#     outfile = paste0(file_path_sans_ext(fname),
#                      "_notoc.Rmd")
#     
#     
#     ind = grep("^---", index)[1:2]
#     
#     yaml = index[seq(ind[1] + 1, ind[2] - 1)]
#     
#     yaml = paste(yaml, collapse = "\n")
#     doc = yaml.load(yaml)
#     doc$output$html_document$toc = NULL
#     doc$output$html_document$toc_depth = NULL
#     doc$output$html_document$toc_float = NULL
#     doc$output$html_document$keep_md = NULL
#     
#     # doc$output$html_document$self_contained = FALSE
#     
#     # remove numbered sections
#     doc$output$html_document$number_sections = NULL
#     
#     if (grepl("^faq", fname)) {
#       doc$output$html_document$includes = NULL
#       doc$output$html_document$self_contained = TRUE
#     }
#     
#     doc$date = NULL
#     doc$title = NULL
#     doc$author = NULL
#     # doc$output$html_document$theme = "null"
#     # doc$output$html_document$highlight = "null"
#     # highlight: null
#     doc$output$html_document$theme = "null"
#     # doc$output$html_document$highlight = "null"
#     # doc$output$html_document$self_contained = "false"
#     
#     
#     yaml = as.yaml(doc)
#     yaml = strsplit(yaml, "\n")[[1]]
#     yaml = gsub("'null'", "null", yaml)
#     yaml = gsub("'false'", "false", yaml)
#     
#     # index[seq(ind[2] + 1, length(index))]
#     index_notoc = c("---", yaml, "---", md)
#     if (subber) {
#       app = "[.][.]/"
#     } else {
#       app = ""
#     }
#     ###############################
#     # Replacing references with the neuroc ones for index
#     ###############################
#     # index_notoc = gsub("(../index.html)", "(neuroc-help)", index_notoc,
#     #                    fixed = TRUE)
#     
#     index_notoc = gsub("(../index.html)", "(..)", index_notoc,
#                        fixed = TRUE)
#     
#     
#     ###############################
#     # Finding references to other tutorials
#     ###############################
#     change_ind = grep(paste0("\\(", app, ".+/index[.]html\\)"),
#                       index_notoc)
#     
#     ###############################
#     # Doing the simple/stupid way of string matching
#     ###############################
#     dumb_string = "XZXZXZXZ"
#     dumb_out = paste0("](", dumb_string, "___", "\\L\\1___", dumb_string, ")")
#     
#     ###############################
#     # replace stuff with dumb_string to split
#     ###############################
#     index_notoc = gsub(paste0("\\]\\(", app, "(.+)/index[.]html\\)"),
#                        dumb_out, index_notoc,
#                        perl = TRUE)
#     
#     # split it
#     index_notoc = strsplit(index_notoc,
#                            split = dumb_string,
#                            fixed = TRUE)
#     # print(index_notoc[change_ind])
#     
#     # replacing with neuroc-help- in the front
#     index_notoc[change_ind] = lapply(
#       index_notoc[change_ind],
#       function(x) {
#         ind = grepl("^___", x)
#         x[ind] = gsub("___", "", x[ind])
#         # Adi is using _ now! 2019/1/10
#         # comment line below
#         # x[ind] = gsub("_", "-", x[ind])
#         
#         
#         # x[ind] = paste0("neuroc-help-", x[ind])
#         x = paste(x, collapse = "")
#         return(x)
#       })
#     
#     # just making character(0) into ""
#     index_notoc = sapply(index_notoc, function(x) {
#       if (length(x) == 0) {
#         x = ""
#       }
#       return(x)
#     })
#     
#     if (file.exists(outfile)) {
#       check = readLines(outfile)
#       
#       if (!identical(check, index_notoc)) {
#         writeLines(text = index_notoc, con = outfile)
#       } else {
#         print("Files are the same, not written!")
#       }
#     } else {
#       writeLines(text = index_notoc, con = outfile)
#     }
#     
#     if (renderIt) {
#       rmarkdown::render(input = outfile)
#     }
#     
#     return(file.exists(outfile))
#   } else {
#     return(FALSE)
#   }
# }
# 
# notoc("index.Rmd",
#       renderIt = FALSE,
#       subber = FALSE,
#       addR = FALSE)
# 
# sapply(all_indices, notoc)
