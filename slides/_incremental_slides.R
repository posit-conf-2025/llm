incremental_slides <- function(
  pattern,
  template = "{{< include {path} >}}",
  ...,
  dir = "assets",
  collapse = "\n\n"
) {
  paths <- fs::dir_ls(dir, regexp = pattern, ...)
  paths <- sort(paths)

  slides <- glue::glue(template, path = paths)
  cat(slides, sep = collapse)
}
