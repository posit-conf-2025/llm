# %%
import chatlas
import dotenv

dotenv.load_dotenv()

# %%
# Read in the recipes from the text files (same as in 10_structured-output)
from pyhere import here

recipe_files = list(here("data/recipes/text").glob("*"))
recipes = [f.read_text() for f in recipe_files]

# %% [markdown]
# Here's an example of the structured output we want to achieve for a single
# recipe:
#
# ```json
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
# ```
#
# We'll use the same Pydantic models we defined in the last exercise.

# %%
from typing import List, Optional

from pydantic import BaseModel, Field


class Ingredient(BaseModel):
    name: str = Field(..., description="Name of the ingredient")
    quantity: float = Field(
        ...,
        description="Quantity as provided (kept as string to allow ranges or fractions)",
    )
    unit: Optional[str] = Field(
        None,
        description="Unit of measure, if applicable",
    )
    notes: Optional[str] = Field(
        None,
        description="Additional notes or preparation details",
    )


class Recipe(BaseModel):
    title: str
    description: str
    ingredients: List[Ingredient]
    instructions: List[str] = Field(..., description="Step-by-step instructions")


# %%
from tqdm import tqdm


def extract_recipe(recipe_text: str) -> Recipe:
    chat = chatlas.ChatOpenAI(model="gpt-4.1-nano")
    return chat.chat_structured(recipe_text, data_model=Recipe)


recipes_data: List[Recipe] = []
for recipe in tqdm(recipes):
    recipes_data.append(extract_recipe(recipe))

# %%
[r.title for r in recipes_data]

# %%
# Can that be a polars DataFrame?
import polars as pl

recipes_df = pl.DataFrame([r.model_dump() for r in recipes_data], strict=False)
recipes_df
