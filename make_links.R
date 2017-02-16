rm(list = ls())
library(rvest)
library(httr)
library(xml2)
fname = "index.html"
base_url = "https://raw.githubusercontent.com/muschellij2/neuroc/master/"
neuroc_ver = "neuroc_development"
# neuroc_ver = ""
root_outdir = file.path("/var", "www", neuroc_ver, "html", "sites",
                   "default", "files")
root_outdir = gsub("//", "/", root_outdir)
outdir = file.path(root_outdir, "help")

doc = read_html(fname)
hrefs = html_nodes(doc, xpath = "//a")
hrefs = xml_attr(hrefs, "href")
hrefs = hrefs[ !grepl("^(http|www)", hrefs)]
hrefs = trimws(hrefs)

hrefs = gsub("index[.]html$", "index_notoc.html", hrefs)
hrefs = hrefs[ file.exists(hrefs)]
folnames = dirname(hrefs)

hrefs = paste0(base_url, hrefs)

hrefs = paste0("wget ", 
               hrefs, " -O ",
               file.path(outdir, 
                         paste0(folnames, ".html"))
)
hrefs = c(hrefs, "", 
          paste("wget", 
                 "https://raw.githubusercontent.com/muschellij2/neurocInstall/master/neurocLite.R",
                 "-O", file.path(root_outdir, "neurocLite.R"))
          )


outfile = paste0("cron_", 
                 ifelse(neuroc_ver == "", "live", "devel"), 
                 ".sh")
writeLines(hrefs, outfile)

