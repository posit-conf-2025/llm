library(ellmer)

recipe_images <- here::here("data/recipes/images")
img_pancakes <- file.path(recipe_images, "EasyBasicPancakes.jpg")
img_pad_thai <- file.path(recipe_images, "PadThai.jpg")

chat <- chat_openai(model = "gpt-4.1-nano")
chat$chat(
  "Give the food in this image a creative recipe title and description.",
  content_image_file(img_pancakes)
)

chat <- chat_openai(model = "gpt-4.1-nano")
chat$chat(
  "Write a recipe to make the food in this image.",
  content_image_file(img_pad_thai)
)
