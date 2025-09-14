# %%
import chatlas
import dotenv

dotenv.load_dotenv()

# %%
from pyhere import here

recipe_txt = here("data/recipes/text/")
txt_cheesecake = (recipe_txt / "PhillyCheesesteak.md").read_text()

# %%
print(txt_cheesecake)

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
# Hint: you can use `Optional` from the `typing` module to indicate that a field
# is not always required.

# %%
from typing import List, Optional

from pydantic import BaseModel, Field


class Ingredient(BaseModel):
    name: ____
    quantity: ____
    unit: Optional[____] = Field(None, description="____")
    notes: Optional[____] = ____


class Recipe(BaseModel):
    title: ____
    description: ____
    ingredients: List[_____]
    instructions: List[____] = Field(..., description="____")


# %%
chat = chatlas.ChatOpenAI(model="gpt-4.1-nano")
recipe = chat.chat_structured(txt_cheesecake, data_model=Recipe)

# %% [markdown]
# `.chat_structured()` returns an instance of the provided Pydantic model, so
# you can access fields directly:

# %%
recipe.title

# %% [markdown]
# Or you can convert it to JSON with pydantic's built-in `.model_dump_json()`
# method:

# %%
print(recipe.model_dump_json(indent=2))
