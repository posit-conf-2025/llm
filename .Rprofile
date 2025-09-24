if (!nzchar(Sys.getenv("CI", ""))) {
  # source("renv/activate.R")
}

local({
  # Make sure posit/rstudio r-universe repos are set
  repos <- getOption("repos")
  repos <- c(
    repos,
    `posit-dev.r-universe.dev` = "https://posit-dev.r-universe.dev",
    `rstudio.r-universe.dev` = "https://rstudio.r-universe.dev"
  )
  options(repos = repos[!duplicated(repos)])
})

if (file.exists(".env") && requireNamespace("dotenv", quietly = TRUE)) {
  dotenv::load_dot_env()
  cli::cli_alert_success("Loaded API keys from {.path .env}")
}
