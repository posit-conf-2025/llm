library(ellmer)

# Read in the recipes from text files (same as in 10_structured-output)
recipe_files <- fs::dir_ls(here::here("data/recipes/text"))
recipes <- purrr::map_chr(recipe_files, brio::read_file)

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

# Use the recipe_type we defined in the last exercise
recipe_type <- type_object(
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

# Extract structured data from all recipes in parallel (fast, may be pricey)
recipes_data <- parallel_chat_structured(
  chat("openai/gpt-4.1-nano"),
  prompts = as.list(recipes),
  type = recipe_type
)

# Hey, it's a table of recipes!
recipes_tbl <- dplyr::as_tibble(recipes_data)
recipes_tbl

# Or use the Batch API to process all recipes (can be slow, but cheap)
res <- batch_chat_structured(
  chat("openai/gpt-4.1-nano"),
  prompts = as.list(recipes),
  type = recipe_type,
  path = here::here("data/recipes/batch_results.json")
)
