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

# Use the type_recipe we defined in the last exercise
type_recipe <- type_object(
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

# Parallel structured extraction (fast, may be pricey) -------------------------
# First, we'll use a simple loop to process each recipe one at a time. This is
# straightforward for our 8 recipes, but would be slow (and expensive) for a
# larger dataset.
recipes_data <- parallel_chat_structured(
  chat("openai/gpt-4.1-nano"),
  prompts = as.list(recipes),
  type = type_recipe
)

# Hey, it's a table of recipes!
recipes_tbl <- dplyr::as_tibble(recipes_data)
recipes_tbl

# Batch API (slower, but cheaper) ----------------------------------------------
# That was pretty easy! But what if we had 10,000 recipes to process? That would
# take a long time, and be pretty expensive. We can save money by using the
# Batch API, which allows us to send multiple requests in a single API call.
#
# With the Batch API, results are processed asynchronously and are completed at
# some point, usually within a few minutes but at most within the next 24 hours.
# Because batching lets providers schedule requests more efficiently, it also
# costs less per token than the standard API.

res <- batch_chat_structured(
  chat("anthropic/claude-3-haiku-20240307"),
  prompts = as.list(recipes),
  type = type_recipe,
  path = here::here("data/recipes/batch_results_r_claude.json")
)

# Save the results -------------------------------------------------------------
# Now, save the results to a JSON file in `data/recipes/recipes.json`. Once
# you've done that, you can open up `11_recipe-app.py` and run the app to see
# your new recipe collection!
jsonlite::write_json(
  res,
  here::here("data/recipes/recipes.json"),
  auto_unbox = TRUE,
  pretty = TRUE
)
