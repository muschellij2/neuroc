if (!require("kirby21.t1")) {
  install.packages("kirby21.t1")
  library(kirby21.t1)
}
if (!require("neurobase")) {
  install.packages("neurobase")
  library(neurobase)
}
kirby21.t1::download_t1_data()
filename = get_t1_filenames(id = 113, visit = 1)
img = neurobase::readnii(filename)
class(img)
ortho2(img)
# get random "slice" of the brain
slice = img[,,124]

