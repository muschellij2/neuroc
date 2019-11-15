## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----cars----------------------------------------------------------------
library(MNITemplate)
library(papayaWidget)
img1 = MNITemplate::readMNI()
img2 = MNITemplate::readMNISeg()


## ------------------------------------------------------------------------
library(neurobase)
ortho2(img1)
ortho2(img2)


## ------------------------------------------------------------------------
papaya(img1)
papaya(img2)


## ------------------------------------------------------------------------
papaya(img1, sync_view = TRUE)
papaya(img2, sync_view = TRUE)


## ------------------------------------------------------------------------
papaya(img1, sync_view = TRUE, hide_toolbar = TRUE, hide_controls = TRUE)


## ------------------------------------------------------------------------
papaya(img2, sync_view = TRUE, hide_toolbar = TRUE, hide_controls = TRUE)

