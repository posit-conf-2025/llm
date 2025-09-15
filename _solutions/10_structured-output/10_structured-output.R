library(ellmer)

# Read in the recipes from text files
recipe_txt <- here::here("data/recipes/text")
txt_waffles <- recipe_txt |>
  file.path("CinnamonPeachOatWaffles.md") |>
  readLines()

# Show the first 500 characters of the first recipe
txt_waffles |> substring(1, 500) |> cat()

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

type_recipe <- type_object(
  title = type_string(),
  description = type_string(),
  ingredients = type_array(
    type_object(
      name = type_string(),
      quantity = type_number(),
      unit = type_string(required = FALSE),
      notes = type_string(required = FALSE)
    ),
  ),
  instructions = type_array(type_string())
)

chat <- chat("openai/gpt-4.1-nano")

chat$chat_structured(txt_waffles, type = type_recipe)
