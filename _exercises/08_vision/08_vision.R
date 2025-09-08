library(ellmer)

recipe_image <- here::here("data/recipes/images/EasyBasicPancakes.jpg")

chat <- chat_ollama(model = "gemma3:4b")
chat$chat(
  "Describe this image in detail",
  content_image_file(recipe_image)
)

chat <- chat_ollama(model = "gemma3:4b")
chat$chat(
  "Write a recipe to make the food in this image",
  content_image_file(recipe_image)
)
