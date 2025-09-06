library(ellmer)

# {
#   "title": "Spicy Mango Salsa Chicken",
#   "description": "A flavorful and vibrant chicken dish...",
#   "ingredients": [
#     {
#       "name": "Chicken Breast",
#       "quantity": "4",
#       "unit": "medium",
#       "notes": "Boneless, skinless"
#     },
#     {
#       "name": "Lime Juice",
#       "quantity": "2",
#       "unit": "tablespoons",
#       "notes": "Fresh"
#     }
#   ],
#   "instructions": [
#     "Preheat grill to medium-high heat.",
#     "In a bowl, combine ...",
#     "Season chicken breasts with salt and pepper.",
#     "Grill chicken breasts for 6-8 minutes per side, or until cooked through.",
#     "Serve chicken topped with the spicy mango salsa."
#   ]
# }

recipe_files <- fs::dir_ls(here::here("data/recipes/text"))
recipes <- purrr::map_chr(recipe_files, brio::read_file)

chat <- chat_ollama(model = "gemma3:4b")
chat <- chat("openai/gpt-5-nano")

chat$chat_structured(
  recipes[1],
  type = type_object(
    title = type_string(),
    description = type_string(),
    ingredients = type_array(
      type_object(
        name = type_string(),
        quantity = type_number(),
        unit = type_string(),
        notes = type_string()
      )
    ),
    instructions = type_array(type_string())
  )
)


res <- parallel_chat_structured(
  chat,
  interpolate("<recipe>\n{{recipes[2:3]}}\n</recipe>"),
  type = type_object(
    title = type_string(),
    description = type_string(),
    ingredients = type_array(
      type_object(
        name = type_string(),
        quantity = type_number(),
        unit = type_string(),
        notes = type_string()
      )
    ),
    instructions = type_array(type_string())
  )
)
