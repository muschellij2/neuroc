library(RNifti)
library(fslr)

fname = system.file( "nifti", "mniLR.nii.gz", package = "oro.nifti")
rpi_img = readNifti(fname)
orientation(rpi_img) = "LAS"

read_img = function(outor) {
  rnif_img = readNifti(fname)
  # print(orientation(rnif_img))
  orientation(rnif_img) = outor
  stopifnot(orientation(rnif_img) == outor)
  rnif_img
}
args = list(c("R", "L"), c("A", "P"), c("I", "S"))
all_types = rbind(
  expand.grid(args[c(1, 2, 3)], stringsAsFactors = FALSE),
  expand.grid(args[c(1, 3, 2)], stringsAsFactors = FALSE),
  expand.grid(args[c(2, 1, 3)], stringsAsFactors = FALSE),
  expand.grid(args[c(2, 3, 1)], stringsAsFactors = FALSE),
  expand.grid(args[c(3, 1, 2)], stringsAsFactors = FALSE),
  expand.grid(args[c(3, 2, 1)], stringsAsFactors = FALSE)
)

all_types$out = paste0(all_types$Var1, all_types$Var2, all_types$Var3)
all_types = all_types$out



checkit2 = function(img) {
  xx = img
  orientation(xx) = "LAS"
  stopifnot(all(rpi_img == xx))
  return(TRUE)
}

out = lapply(all_types, function(x) {
  print(x)
  img = read_img(x)
  try({checkit2(img)})
})
stopifnot(all(sapply(out, isTRUE)))


checkit = function(img) {
  out = rpi_orient(img)
  stopifnot(all(rpi_img == out$img))
  return(TRUE)
}

getForms(fname)
x = "SLP"
img = read_img(x)
fslgetorient(img)
getForms(img)
out = rpi_orient(img)

out = lapply(all_types, function(x) {
  print(x)
  img = read_img(x)
  try({checkit(img)})
  })

bad = all_types[ !sapply(out, isTRUE)]
good = all_types[ sapply(out, isTRUE)]





