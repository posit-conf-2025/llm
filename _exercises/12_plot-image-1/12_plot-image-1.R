library(readr)
library(ellmer)
library(ggplot2)

# Step 1: Make a scatter plot of the typical mtcars dataset
mtcars <- read_csv(here::here("data/mtcars.csv"))

ggplot(mtcars) +
  aes(x = wt, y = mpg) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title = "MPG vs Weight",
    x = "Weight (1000 lb)",
    y = "Miles per Gallon (mpg)"
  ) +
  theme_bw()

# Step 2: Ask Claude 4 Sonnet to interpret the plot.
# (Hint: see `content_image_...`)
chat <- chat("____", echo = "output")
chat$chat(
  "Interpret this plot.",
  ____()
)
