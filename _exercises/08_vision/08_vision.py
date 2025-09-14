# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %%
recipe_images = here("data/recipes/images/")
img_ziti = recipe_images / "ClassicBakedZiti.jpg"
img_mac_cheese = recipe_images / "CreamyCrockpotMacAndCheese.jpg"

# %% [markdown]
# Ask OpenAI's `gpt-4.1-nano` to give a creative recipe title and description
# for the ziti image.
chat = ____
chat.chat(
    "Give the food in this image a creative recipe title and description.",
    chatlas.____(img_ziti),
)

# %% [markdown]
# In a new chat, ask it to write a recipe for the food it sees in the Mac &
# Cheese image. (Don't tell it that it's Mac & Cheese!)
chat = ____
chat.chat(
    "Write a recipe to make the food in this image.", chatlas.____(img_mac_cheese)
)
