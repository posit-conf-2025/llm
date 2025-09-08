library(readr)
library(ellmer)

m <- 32
u <- (seq_len(floor(sqrt(m))) - 0.5) / floor(sqrt(m))
grid <- as.matrix(expand.grid(x = u, y = u))

eps <- 1 / (2 * sqrt(m))
jitter <- matrix(runif(length(grid), -eps, eps), ncol = 2)
grid_jitter <- pmin(pmax(grid + jitter, 0), 1)

plot(
  x = grid_jitter[, 1],
  y = grid_jitter[, 2],
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
