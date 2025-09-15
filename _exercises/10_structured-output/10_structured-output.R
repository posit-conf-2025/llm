library(ellmer)

# Read in the recipes from text files
recipe_txt <- here::here("data/recipes/text")
txt_waffles <- recipe_txt |>
  file.path("CinnamonPeachOatWaffles.md") |>
  brio::read_file() # Like readLines() but all in one string

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
#'
#' Hint: You can use `required = FALSE` in `type_*()` functions to indicate that
#' a field is optional.

type_recipe <- type_____(
  title = ____(),
  description = ____(),
  ingredients = ____(
    type_object(
      name = ____(),
      quantity = ____(),
      unit = ____(),
      notes = ____()
    )
  ),
  instructions = type_array(____())
)

chat <- chat("openai/gpt-4.1-nano")

chat$chat_structured(txt_waffles, type = type_recipe)
