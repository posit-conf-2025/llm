# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %%
recipe_images = here("data/recipes/images/")
img_ziti = recipe_images / "ClassicBakedZiti.jpg"
img_mac_cheese = recipe_images / "CreamyCrockpotMacAndCheese.jpg"

# %%
chat = chatlas.ChatOpenAI(model="gpt-4.1-nano")
chat.chat(
    "Give the food in this image a creative recipe title and description.",
    chatlas.content_image_file(img_ziti),
)

# %%
chat = chatlas.ChatOpenAI(model="gpt-4.1-nano")
chat.chat(
    "Write a recipe to make the food in this image.",
    chatlas.content_image_file(img_mac_cheese),
)
