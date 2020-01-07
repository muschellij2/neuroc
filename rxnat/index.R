## ----setup, include=FALSE-----------------------------------------------------
library(Rxnat)
knitr::opts_chunk$set(echo = TRUE, cache = FALSE, comment = "")


## ----eval=FALSE---------------------------------------------------------------
## 
## source("http://neuroconductor.org/neurocLite.R")
## neuro_install("Rxnat", release = "stable")
## 
## # install.packages("remotes")
## remotes::install_github("adigherman/Rxnat")


## ----eval=FALSE---------------------------------------------------------------
## nitrc <- xnat_connect('https://nitrc.org/ir', username='XXXX', password='YYYY', xnat_name=NULL)


## ----eval=FALSE---------------------------------------------------------------
## nitrc <- xnat_connect('https://nitrc.org/ir', xnat_name='NITRC')


## ----eval=FALSE---------------------------------------------------------------
## hcp <-xnat_connect('https://db.humanconnectome.org', xnat_name = "hcp")
## hcp_projects <- hcp$projects()
## head(hcp_projects[c('id','name')])
##             id                                        name
## 1 CCF_DMCC_STG                        DMCC Staging Project
## 2     HCP_1200            WU-Minn HCP Data - 1200 Subjects
## 3      HCP_500 WU-Minn HCP Data &#150; 500 Subjects + MEG2
## 4  HCP_500_RST      HCP 500 Subject + MEG2 Restricted Data
## 5      HCP_900        WU-Minn HCP Data - 900 Subjects + 7T
## 6    HCP_Coded                                   HCP_Coded


## ----eval=FALSE---------------------------------------------------------------
## hcp_subjects <- hcp$subjects()
## head(hcp_subjects)
##        project                  ID  label gender handedness yob education ses group race ethnicity
## 1 HCP_Subjects ConnectomeDB_S02177 100004      M         NA  NA        NA  NA    NA   NA        NA
## 2 HCP_Subjects ConnectomeDB_S01982 100206      M         NA  NA        NA  NA    NA   NA        NA
## 3 HCP_Subjects ConnectomeDB_S00230 100307      F         NA  NA        NA  NA    NA   NA        NA
## 4 HCP_Subjects ConnectomeDB_S00381 100408      M         NA  NA        NA  NA    NA   NA        NA
## 5 HCP_Subjects ConnectomeDB_S01590 100610      M         NA  NA        NA  NA    NA   NA        NA
## 6 HCP_Subjects ConnectomeDB_S00551 101006      F         NA  NA        NA  NA    NA   NA        NA


## ----eval=FALSE---------------------------------------------------------------
## hcp_experiments <- hcp$experiments()
## head(hcp_experiments)
##        project subject                  ID                type      label age
## 1 HCP_Subjects  100206 ConnectomeDB_E13304  xnat:mrSessionData  100206_3T  26
## 2 HCP_Subjects  100307 ConnectomeDB_E03657  xnat:mrSessionData  100307_3T  26
## 3 HCP_Subjects  100307 ConnectomeDB_E10373 xnat:megSessionData 100307_MEG  NA
## 4 HCP_Subjects  100408 ConnectomeDB_E03658  xnat:mrSessionData  100408_3T  31
## 5 HCP_Subjects  100610 ConnectomeDB_E11186  xnat:mrSessionData  100610_3T  26
## 6 HCP_Subjects  100610 ConnectomeDB_E24170  xnat:mrSessionData  100610_7T  26


## ----eval=FALSE---------------------------------------------------------------
## ConnectomeDB_E13304_resources <- hcp$get_xnat_experiment_resources('ConnectomeDB_E13304')
## head(ConnectomeDB_E13304_resources[c('Name','URI')])
##                                  Name                                                                                                        URI
## 1            100206_3T_BIAS_BC.nii.gz            /data/experiments/ConnectomeDB_E13304/scans/101/resources/274961/files/100206_3T_BIAS_BC.nii.gz
## 2          100206_3T_BIAS_32CH.nii.gz          /data/experiments/ConnectomeDB_E13304/scans/102/resources/274962/files/100206_3T_BIAS_32CH.nii.gz
## 3           100206_3T_T1w_MPR1.nii.gz           /data/experiments/ConnectomeDB_E13304/scans/103/resources/274963/files/100206_3T_T1w_MPR1.nii.gz
## 4           100206_3T_T2w_SPC1.nii.gz           /data/experiments/ConnectomeDB_E13304/scans/106/resources/274964/files/100206_3T_T2w_SPC1.nii.gz
## 5 100206_3T_FieldMap_Magnitude.nii.gz /data/experiments/ConnectomeDB_E13304/scans/107/resources/274965/files/100206_3T_FieldMap_Magnitude.nii.gz
## 6     100206_3T_FieldMap_Phase.nii.gz     /data/experiments/ConnectomeDB_E13304/scans/108/resources/274966/files/100206_3T_FieldMap_Phase.nii.gz


## ----eval=FALSE---------------------------------------------------------------
## hcp_500_age_26 <- query_scan_resources(hcp,age='26', project='HCP_500')
## head(hcp_500_age_26[c("subject_ID","experiment_ID", "Project", "Age")])
##            subject_ID       experiment_ID Project Age
## 1 ConnectomeDB_S00230 ConnectomeDB_E03657 HCP_500  26
## 2 ConnectomeDB_S00231 ConnectomeDB_E03664 HCP_500  26
## 3 ConnectomeDB_S00234 ConnectomeDB_E03684 HCP_500  26
## 4 ConnectomeDB_S00235 ConnectomeDB_E03690 HCP_500  26
## 5 ConnectomeDB_S00236 ConnectomeDB_E03694 HCP_500  26
## 6 ConnectomeDB_S00237 ConnectomeDB_E03988 HCP_500  26


## ----eval=FALSE---------------------------------------------------------------
## scan_resources <- get_scan_resources(hcp,'ConnectomeDB_E03657')
## scan_resources[1,"Name"]
## [1] "100307_3T_BIAS_BC.nii.gz"
## > scan_resources[1,"URI"]
## [1] "/data/experiments/ConnectomeDB_E03657/scans/101/resources/69128/files/100307_3T_BIAS_BC.nii.gz"


## ----eval=FALSE---------------------------------------------------------------
## > download_xnat_file(hcp,"/data/experiments/ConnectomeDB_E03657/scans/101/resources/69128/files/100307_3T_BIAS_BC.nii.gz")
## [1] "/var/folders/wb/l7jtkdy14f761vm4xr9zxjj80000gn/T//RtmpFfYbQ7/100307_3T_BIAS_BC.nii.gz"


## ----eval=FALSE---------------------------------------------------------------
## download_xnat_dir(hcp, experiment_ID='ConnectomeDB_E03657',scan_type='T2w', verbose=TRUE)
## Downloading: 28 MB     [1] "/var/folders/wb/l7jtkdy14f761vm4xr9zxjj80000gn/T//RtmpFfYbQ7/ConnectomeDB_E03657.zip"
## 
## 
## # Session Info
## 

## -----------------------------------------------------------------------------
devtools::session_info()

