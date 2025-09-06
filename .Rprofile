source("renv/activate.R")

if (file.exists(".env") && requireNamespace("dotenv", quietly = TRUE)) {
  dotenv::load_dot_env()
  cli::cli_alert_success("Loaded API keys from {.path .env}")
}
