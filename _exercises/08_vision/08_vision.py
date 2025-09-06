#%%
import chatlas
from dotenv import load_dotenv
from pyhere import here

load_dotenv()

#%%
recipe_image = here("data/recipes/images/ClassicBakedZiti.jpg")

#%%
chat = chatlas.ChatOllama(model="gemma3:4b")
chat.chat(
  "Give the food in this image a creative recipe title.",
  chatlas.content_image_file(recipe_image)
)

#%%
chat = chatlas.ChatOllama(model="gemma3:4b")
chat.chat(
  "Write a recipe for the meal in this image.",
  chatlas.content_image_file(recipe_image)
)