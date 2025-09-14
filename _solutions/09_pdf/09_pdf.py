# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %%
recipe_pdfs = here("data/recipes/pdf/")
pdf_cheesesteak = recipe_pdfs / "PhillyCheesesteak.pdf"

# %%
chat = chatlas.ChatOpenAI(model="gpt-4.1-nano")
chat.chat(
    "Summarize the recipe in this PDF into a list of ingredients "
    "and the steps to follow to make the recipe.",
    chatlas.content_pdf_file(pdf_cheesesteak),
)
