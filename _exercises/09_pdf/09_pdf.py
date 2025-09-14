# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %%
recipe_pdfs = here("data/recipes/pdf/")
pdf_cheesesteak = recipe_pdfs / "PhillyCheesesteak.pdf"

# %% [markdown]
# Ask OpenAI's `gpt-4.1-nano` to turn this messy PDF print-out of a Philly
# Cheesesteak recipe into a clean list of ingredients and steps to follow.

# %%
chat = chatlas.____
chat.chat(
    "____",
    chatlas.____(pdf_cheesesteak),
)
