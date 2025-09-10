library(readr)
library(dplyr)

penguins <- read_csv(here::here("data/penguins.csv"))

island_summary <- penguins |>
  group_by(island) |>
  summarize(
    sample_size = n(),
    prop_female = sum(sex == "female", na.rm = TRUE) / sum(!is.na(sex)),

    mean_bill_depth_mm = mean(bill_depth_mm, na.rm = TRUE),
    std_bill_depth_mm = sd(bill_depth_mm, na.rm = TRUE),

    mean_flipper_length_mm = mean(flipper_length_mm, na.rm = TRUE),
    std_flipper_length_mm = sd(flipper_length_mm, na.rm = TRUE),

    mean_body_mass_g = mean(body_mass_g, na.rm = TRUE),
    std_body_mass_g = sd(body_mass_g, na.rm = TRUE)
  ) |>
  arrange(island)

island_summary
