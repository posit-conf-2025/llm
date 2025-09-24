# Task ------------------------------------------------------------------------
library(ellmer)

# **Step 1:** Run the code below as-is to try the task without any extra
# context. How does the model do? Does it know enough about the {weathR}
# package to complete the task?
#
# **Step 2:** Now, let's add some context. Head over to GitHub repo for {weathR}
# (link in `docs.R.md`). Copy the project description from the `README.md` and
# paste it into the `docs.py.md` file.
#
# **Step 3:** Uncomment the extra lines to include these docs in the prompt and
# try again.

chat <- chat(
  "anthropic/claude-3-5-sonnet-20241022",
  echo = "output",
  system_prompt = brio::read_file(here::here(
    "_solutions/15_coding-assistant/docs.R.md"
  ))
)

chat$chat(
  # Task prompt
  paste(
    "Write a simple function that takes latitude and longitude as inputs",
    "and returns the weather forecast for that location using the {weathR}",
    "package. Keep the function concise and simple and don't include error",
    "handling or data re-formatting. Include documentation in roxygen2 format,",
    "including examples for NYC and Atlanta, GA."
  )
)

# Result ----------------------------------------------------------------------

#' Get Weather Forecast for a Location
#'
#' Retrieves the weather forecast for a given latitude and longitude using the
#' National Weather Service API
#'
#' @param lat Numeric latitude value
#' @param lon Numeric longitude value
#' @return A dataframe containing forecast data including time and temperature
#' @export
#'
#' @examples
#' # Get forecast for New York City (Central Park)
#' get_forecast(40.768473, -73.976004)
#'
#' # Get forecast for Atlanta, GA
#' get_forecast(33.749045, -84.388792)
get_forecast <- function(lat, lon) {
  weathR::point_forecast(lat = lat, lon = lon)
}
