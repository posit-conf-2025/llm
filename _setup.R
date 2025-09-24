# Install {pak} (it's fast and smart at installing packages)
if (!requireNamespace("pak", quietly = TRUE)) {
  # fmt: skip
  install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch))
}

# Now install the packages we need for the workshop
pak::pak(c(
  "askpass",
  "base64enc",
  "beepr",
  "brio",
  "bsicons",
  "rstudio/bslib", # remove "rstudio/" to use bslib from CRAN
  "digest",
  "dotenv",
  "dplyr",
  "ellmer",
  "forcats",
  "fs",
  "ggplot2",
  "here",
  "leaflet",
  "magick",
  "mcptools",
  "purrr",
  "posit-dev/querychat/pkg-r",
  "ragnar",
  "reactable",
  "readr",
  "scales",
  "rstudio/shiny", # remove "rstudio/" to use shiny from CRAN
  "posit-dev/shinychat/pkg-r",
  "tidyr",
  "vitals",
  "watcher",
  "weathR"
))
