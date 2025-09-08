library(ellmer)

# Read in the recipes from text files
recipe_files <- fs::dir_ls(here::here("data/recipes/text"))
recipes <- purrr::map_chr(recipe_files, brio::read_file)

# Show the first 500 characters of the first recipe
recipes[1] |> substring(1, 500) |> cat()

#' Here's an example of the structured output we want to achieve for a single
#' recipe:
#'
#' {
#'   "title": "Spicy Mango Salsa Chicken",
#'   "description": "A flavorful and vibrant chicken dish...",
#'   "ingredients": [
#'     {
#'       "name": "Chicken Breast",
#'       "quantity": "4",
#'       "unit": "medium",
#'       "notes": "Boneless, skinless"
#'     },
#'     {
#'       "name": "Lime Juice",
#'       "quantity": "2",
#'       "unit": "tablespoons",
#'       "notes": "Fresh"
#'     }
#'   ],
#'   "instructions": [
#'     "Preheat grill to medium-high heat.",
#'     "In a bowl, combine ...",
#'     "Season chicken breasts with salt and pepper.",
#'     "Grill chicken breasts for 6-8 minutes per side, or until cooked through.",
#'     "Serve chicken topped with the spicy mango salsa."
#'   ]
#' }

recipe_type <- type_object(
  title = type_string(),
  description = type_string(),
  ingredients = type_array(
    type_object(
      name = type_string(),
      quantity = type_number(),
      unit = type_string(),
      notes = type_string()
    ),
    instructions = type_array(type_string())
  )
)

chat <- chat("openai/gpt-4.1-nano")

chat$chat_structured(recipes[1], type = recipe_type)
