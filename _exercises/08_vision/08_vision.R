library(ellmer)

recipe_images <- here::here("data/recipes/images")
img_pancakes <- file.path(recipe_images, "EasyBasicPancakes.jpg")
img_pad_thai <- file.path(recipe_images, "PadThai.jpg")

#' Ask OpenAI's `gpt-4.1-nano` to give a creative recipe title and description
#' for the pancakes image.
chat <- ____
chat$chat(
  "____",
  ____(img_pancakes)
)

#' In a new chat, ask it to write a recipe for the food it sees in the Pad Thai
#' image. (Don't tell it that it's Pad Thai!)
chat <- ____
chat$chat(
  "Write a recipe to make the food in this image.",
  ____(img_pad_thai)
)
