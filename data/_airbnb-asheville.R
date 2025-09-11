library(dplyr)
library(ellmer)
library(janitor)

# https://insideairbnb.com/get-the-data/
listings <- readr::read_csv(
  "https://data.insideairbnb.com/united-states/nc/asheville/2025-06-17/data/listings.csv.gz"
)

listings <-
  listings |>
  clean_names() |>
  remove_empty("cols") |>
  select(
    id,
    name,
    description,
    zip_code = neighbourhood_cleansed,
    latitude,
    longitude,
    property_type,
    room_type,
    n_accommodates = accommodates,
    n_bathrooms = bathrooms,
    n_bedrooms = bedrooms,
    n_beds = beds,
    amenities,
    price,
    minimum_nights,
    maximum_nights,
    availability_365,
    n_reviews = number_of_reviews,
    first_review,
    last_review,
    n_reviews_per_month = reviews_per_month,
    score_rating = review_scores_rating,
    score_cleanliness = review_scores_cleanliness,
    score_location = review_scores_location,
    score_value = review_scores_value,
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_n_listings = calculated_host_listings_count,
    url_listing = listing_url,
    url_picture = picture_url,
  ) |>
  mutate(
    zip_code = as.character(zip_code),
    # Prevent having to do weird polars things with large integers later...
    id = paste0("l_", id),
    host_id = paste0("h_", host_id),
    price = as.numeric(gsub("[$,]", "", price)),
    amenities = purrr::map_chr(amenities, function(x) {
      paste(unlist(jsonlite::fromJSON(x)), collapse = ";")
    })
  )


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
  zip_codes <- listings |> count(zip_code, sort = TRUE)
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
