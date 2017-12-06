## ----setup, include=FALSE------------------------------------------------
library(kirby21.smri)
library(kirby21.base)
library(plyr)
library(dplyr)
library(EveTemplate)
library(neurobase)
library(ANTsR)
library(extrantsr)
library(ggplot2)
library(reshape2)
library(stringr)
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "",
                      cache.path = "index_cache/html/")

## ----reg_imgs, cache = FALSE---------------------------------------------
library(neurobase)
mods = c("T1", "T2", "FLAIR")
norm_reg_files = file.path("..", 
                     "preprocess_mri_within", 
                     paste0("113-01-", mods, "_norm_eve.nii.gz")
                     )
names(norm_reg_files) = mods
norm_reg_imgs = lapply(norm_reg_files, readnii)

## ----eve_res, cache = FALSE----------------------------------------------
library(EveTemplate)
eve_brain_fname = getEvePath("Brain")
eve_brain = readnii(eve_brain_fname)
eve_brain_mask = readEve(what = "Brain_Mask")
norm_reg_imgs = lapply(norm_reg_imgs, mask_img, mask = eve_brain_mask)

## ----eve_res_plot, cache = TRUE------------------------------------------
lapply(norm_reg_imgs, double_ortho, x = eve_brain)

## ----eve_labs, cache=FALSE-----------------------------------------------
eve_labels = readEveMap(type = "II")
unique_labs = eve_labels %>% 
  c %>% 
  unique %>% 
  sort 
head(unique_labs)
lab_df = getEveMapLabels(type = "II")
head(unique(lab_df$integer_label))
all( unique_labs %in% lab_df$integer_label)

## ----plot_eve_labs-------------------------------------------------------
ortho2(eve_labels)

## ----plot_eve_labs_color-------------------------------------------------
cols = rgb(lab_df$color_r/255, lab_df$color_g, 
           lab_df$color_b, maxColorValue = 255)
breaks = unique_labs
ortho2(eve_labels, col = cols, breaks = c(-1, breaks))

## ----plot_eve_labs_color_spect-------------------------------------------
library(RColorBrewer)
rf <- colorRampPalette(rev(brewer.pal(11,'Spectral')))
cols <- rf(length(unique_labs))
ortho2(eve_labels, col = cols, breaks = c(-1, breaks))

## ----plot_eve_labs_color_spect_random------------------------------------
set.seed(20161008)
ortho2(eve_labels, col = sample(cols), breaks = c(-1, breaks))

## ----eve_labs_t1---------------------------------------------------------
set.seed(20161008)
ortho2(norm_reg_imgs$T1, eve_labels, 
       col.y = alpha(sample(cols), 0.5), ybreaks = c(-1, breaks))

## ----seq_df, cache=FALSE-------------------------------------------------
df = data.frame(T1 = norm_reg_imgs$T1[ eve_brain_mask == 1],
                T2 = norm_reg_imgs$T2[ eve_brain_mask == 1],
                FLAIR = norm_reg_imgs$FLAIR[ eve_brain_mask == 1],
                integer_label = eve_labels[ eve_brain_mask == 1]
                )

## ----long, cache=FALSE---------------------------------------------------
library(reshape2)
library(dplyr)
long = reshape2::melt(df, 
                      id.vars = "integer_label")
head(long)

## ----long_join, cache=FALSE----------------------------------------------
long = left_join(long, lab_df, by = "integer_label")
long = long %>% 
  select(-color_r, -color_g, -color_b)

## ----stats, cache=FALSE--------------------------------------------------
stats = long %>% 
  group_by(integer_label, text_label, right_left, structure, variable) %>% 
  summarise(mean = mean(value),
            median = median(value),
            sd = sd(value)) %>% 
  select(variable, text_label, mean, median, sd, everything()) %>% 
  ungroup
head(stats)

## ----thal----------------------------------------------------------------
library(stringr)
stats %>% filter(str_detect(structure, "thalamus")) %>% 
  select(text_label, variable, mean) %>% 
  arrange(variable, text_label)

## ----plot_fcns-----------------------------------------------------------
transparent_legend =  theme(
  legend.background = element_rect(
    fill = "transparent"),
  legend.key = element_rect(fill =
                              "transparent", 
                            color = "transparent")
)

## ----gg_thalamus_dist----------------------------------------------------
 long %>% filter(str_detect(structure, "thalamus")) %>% 
  ggplot(aes(x = value, colour = factor(right_left))) + 
  geom_line(stat = "density") + facet_wrap(~variable, ncol = 1) +
    theme(legend.position = c(0.2, 0.5),
        legend.direction = "horizontal",
        text = element_text(size = 24)) +
  guides(colour = guide_legend(title = NULL)) +
  transparent_legend

## ----gg_thalamus_box-----------------------------------------------------
 long %>% filter(str_detect(structure, "thalamus")) %>% 
  ggplot(aes(x = variable, y = value, colour = factor(right_left))) + 
  geom_boxplot() +
    theme(legend.position = c(0.2, 0.85),
        legend.direction = "horizontal",
        text = element_text(size = 24)) +
  guides(colour = guide_legend(title = NULL)) +
  transparent_legend


## ----eve_to_t1_files, cache = TRUE---------------------------------------
eve_stub = "Eve_to_Subject"
outfile = paste0(eve_stub, "_T1.nii.gz")
lab_outfile = paste0(eve_stub, "_Labels.nii.gz")
outfiles = c(outfile, lab_outfile)

n4_files = file.path("..", 
                     "preprocess_mri_within", 
                     paste0("113-01-", mods, "_proc_N4_SS.nii.gz")
                     )
names(n4_files) = mods

## ----eve_to_t1, cache = TRUE---------------------------------------------
if ( !all( file.exists(outfiles) )) {
  reg = extrantsr::registration(
    filename = eve_brain_fname,
    template.file = n4_files["T1"],
    other.files = eve_labels,
    other.outfiles = lab_outfile,
    interpolator = "NearestNeighbor",
    typeofTransform = "SyN")
} 

## ----read_proc_imgs, cache = FALSE---------------------------------------
n4_proc_imgs = lapply(n4_files, readnii)
native_eve_labels = readnii(lab_outfile)

## ----native_eve_labs-----------------------------------------------------
set.seed(20161008)
ortho2(n4_proc_imgs$T1, native_eve_labels, 
       col.y = alpha(sample(cols), 0.5), 
       ybreaks = c(-1, breaks))

## ----native_df, cache=FALSE----------------------------------------------
native_mask = n4_proc_imgs$T1 > 0
norm_imgs = lapply(n4_proc_imgs, zscore_img, 
                   mask = native_mask)
native_df = data.frame(
  T1 = norm_imgs$T1[ native_mask == 1 ], 
  T2 = norm_imgs$T2[ native_mask == 1 ],
  FLAIR = norm_imgs$FLAIR[ native_mask == 1 ],
  integer_label = native_eve_labels[ native_mask == 1 ]
)
nlong = reshape2::melt(native_df, 
                      id.vars = "integer_label")

## ----native_long_join, cache=FALSE---------------------------------------
nlong = left_join(nlong, lab_df, 
                  by = "integer_label")
nlong = nlong %>% 
  select(-color_r, -color_g, -color_b)

## ----gg_thalamus_native_dist---------------------------------------------
g = nlong %>% filter(str_detect(structure, "thalamus")) %>% 
  ggplot(aes(x = value, colour = factor(right_left))) + 
  geom_line(stat = "density") + facet_wrap(~variable, ncol = 1) +
    theme(legend.position = c(0.2, 0.5),
        legend.direction = "horizontal",
        text = element_text(size = 24)) +
  guides(colour = guide_legend(title = NULL)) +
  transparent_legend
g + ggtitle("Native Space Thalamus")
(g + ggtitle("Eve Space Thalamus")) %+% 
  (nlong %>% filter(str_detect(structure, "thalamus")))
rm(list = "g")

