library(dplyr)
library(ellmer)
library(janitor)

# https://insideairbnb.com/get-the-data/
listings <- readr::read_csv(
  "https://data.insideairbnb.com/united-states/nc/asheville/2025-06-17/visualisations/listings.csv"
)

listings <-
  listings |>
  clean_names() |>
  remove_empty("cols") |>
  rename(zip_code = neighbourhood) |>
  mutate(
    zip_code = as.character(zip_code),
    # Prevent having to do weird polars things with large integers later...
    id = paste0("l_", id),
    host_id = paste0("h_", host_id)
  )

zip_codes <- listings |> count(zip_code, sort = TRUE)

path_zip_codes_recode <- here::here("data/_asheville-zip-codes.csv")

if (file.exists(path_zip_codes_recode)) {
  zip_codes_recode <- readr::read_csv(
    path_zip_codes_recode,
    col_types = readr::cols(
      zip_code = readr::col_character(),
      neighborhood = readr::col_character()
    )
  )
} else {
  zip_codes_recode <- parallel_chat_structured(
    chat("openai/gpt-5-nano"),
    interpolate(
      paste(
        "You are a helpful assistant that provides neighborhood names for Asheville, NC",
        "based on zip codes. The neighborhood name is used for display purposes",
        "when describing the location an Airbnb listing. The zip code is {{zip_code}}."
      ),
      zip_code = zip_codes$zip_code
    ),
    type = type_object(
      "The zip code and neighborhood name.",
      zip_code = type_string(),
      neighborhood = type_string("The neighborhood name.")
    )
  )
  readr::write_csv(zip_codes_recode, path_zip_codes_recode)
}

listings <- listings |>
  left_join(zip_codes_recode, by = "zip_code") |>
  relocate(neighborhood, .after = zip_code)

readr::write_csv(
  listings,
  here::here("data/airbnb-asheville.csv"),
  na = ""
)
