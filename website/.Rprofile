source_parent_r_profile <- function() {
  if (!file.exists("../.Rprofile")) return()
  owd <- setwd("..")
  on.exit(setwd(owd))
  if (file.exists(".Renviron")) {
    readRenviron(".Renviron")
  }
  source(".Rprofile")
}

source_parent_r_profile()
