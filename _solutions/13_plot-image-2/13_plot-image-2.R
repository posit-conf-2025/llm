library(readr)
library(ellmer)
library(ggplot2)

m <- 32
u <- (seq_len(floor(sqrt(m))) - 0.5) / floor(sqrt(m))
grid <- as.matrix(expand.grid(x = u, y = u))

eps <- 1 / (2 * sqrt(m))
jitter <- matrix(runif(length(grid), -eps, eps), ncol = 2)
grid_jitter <- pmin(pmax(grid + jitter, 0), 1)

ggplot() +
  aes(x = grid_jitter[, 1], y = grid_jitter[, 2]) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title = "MPG vs Weight",
    x = "Weight (1000 lb)",
    y = "Miles per Gallon (mpg)"
  ) +
  theme_bw()

chat <- chat("anthropic/claude-sonnet-4-20250514", echo = "output")
chat$chat(
  "Interpret this plot of mtcars.",
  content_image_plot()
)
