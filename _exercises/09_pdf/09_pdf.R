library(ellmer)

recipe_pdfs <- here::here("data/recipes/pdf")
pdf_waffles <- file.path(recipe_pdfs, "CinnamonPeachOatWaffles.pdf")

# Ask OpenAI's `gpt-4.1-nano` to turn this messy PDF print-out of a waffle
# recipe into a clean list of ingredients and steps to follow.
chat <- ____
chat$chat(
  "____",
  ____(pdf_waffles)
)
