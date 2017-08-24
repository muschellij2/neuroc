rm(list = ls())
library(dplyr)
library(readr)
x = readLines("index.Rmd")
x = trimws(x)
x = grep("index[.]html", x, value = TRUE)
x = gsub(".*\\]\\((.*)/index.html\\).*", "\\1", x)

df = data_frame(file = x)
df = df %>% 
  mutate(
    neuroc_link = paste0("neuroc-help-", gsub("_", "-", file)),
    url = paste0("https://raw.githubusercontent.com", 
                  "/muschellij2/neuroc/master/", 
                  file, "/index_notoc.html"),
    out_file = paste0(file, ".html")
    )
df$command = paste0("wget -O ", df$out_file, " ", df$url)
write_csv(df, path = "link_table.csv")

writeLines(df$command, con = "wget_link_table.sh")

