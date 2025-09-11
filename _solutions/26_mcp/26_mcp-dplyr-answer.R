library(readr)
library(dplyr)

listings <- read_csv(here::here("data/airbnb-asheville.csv"))

hot_room_types <-
  listings |>
  group_by(neighborhood, room_type) |>
  summarize(
    total_listings = n(),
    avg_price = round(mean(price, na.rm = TRUE), 2),
    avg_score = round(mean(score_rating, na.rm = TRUE), 2),
    total_occupied_days = sum(365 - availability_365, na.rm = TRUE),
    avg_occupied_days = (365 - mean(availability_365, na.rm = TRUE)),
    total_reviews = sum(n_reviews, na.rm = TRUE),
    .groups = "drop_last"
  ) |>
  slice_max(total_reviews / total_listings, n = 1) |>
  arrange(desc(avg_occupied_days))

hot_room_types
