# %%
import chatlas
import dotenv

dotenv.load_dotenv()

# %%
# Read in the recipes from the text files (this time all of the files)
from pyhere import here

recipe_files = list(here("data/recipes/text").glob("*"))
recipes = [f.read_text() for f in recipe_files]

# %% [markdown]
# We'll use the same Pydantic models we defined in `10_structured-output`.
# Optional: Replace the models in the next cell with your own from that
# exercise.

# %%
from typing import List, Optional

from pydantic import BaseModel, Field


class Ingredient(BaseModel):
    name: str = Field(..., description="Name of the ingredient")
    quantity: float | None = Field(default=1, description="Quantity as provided")
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
    image_url: Optional[str] = Field(..., description="URL of an image of the dish")
    ingredients: List[Ingredient]
    instructions: List[str] = Field(..., description="Step-by-step instructions")


# %% [markdown]
# First, we'll use a simple loop to process each recipe one at a time. This is
# straightforward for our 8 recipes, but would be slow (and expensive) for a
# larger dataset.
#
# In a future version of `chatlas` (soon after conf!), you will be able to use
# `chatlas.parallel_chat_structured()` to do this truly in parallel!

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

# %% [markdown]
# That was pretty easy! But what if we had 10,000 recipes to process? That would
# take a long time, and be pretty expensive. We can save money by using the
# Batch API, which allows us to send multiple requests in a single API call.
#
# With the Batch API, results are processed asynchronously and are completed at
# some point, usually within a few minutes but at most within the next 24 hours.
# Because batching lets providers schedule requests more efficiently, it also
# costs less per token than the standard API.

# %%
from chatlas import batch_chat_structured

chat = chatlas.ChatAnthropic(model="claude-3-haiku-20240307")
res = ____(
    chat=chat,
    prompts=____,
    data_model=____,
    path=here("data/recipes/batch_results_py_claude.json"),
)

# %% [markdown]
# Now, save the results to a JSON file in `data/recipes/recipes.json`. Once
# you've done that, you can open up `11_recipe-app.py` and run the app to see
# your new recipe collection!

# %%
import json

recipes_structured = [r.model_dump() for r in res]

json.dump(recipes_structured, open(here("data/recipes/recipes.json"), "w"), indent=2)
