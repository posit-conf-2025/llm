# %%
import chatlas
import dotenv

dotenv.load_dotenv()

# %%
from pyhere import here

recipe_files = list(here("data/recipes/text").glob("*"))
recipes = [f.read_text() for f in recipe_files]

# %%
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
chat = chatlas.ChatOpenAI(model="gpt-5-nano")
chat.extract_data(recipes[0], data_model=Recipe)
