library(readr)
library(ellmer)

mtcars_df <- read_csv(here::here("data/mtcars.csv"))

plot(
  x = mtcars_df$wt,
  y = mtcars_df$mpg,
  pch = 19, # filled circles
  col = "steelblue",
  cex = 1.1,
  xlab = "Weight (1000 lb)",
  ylab = "Miles per Gallon (mpg)",
  main = "MPG vs Weight"
)

chat <- chat("openai/gpt-5", echo = "output")
chat$chat(
  "Interpret this plot.",
  content_image_plot()
)
