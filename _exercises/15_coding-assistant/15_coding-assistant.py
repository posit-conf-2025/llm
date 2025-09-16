# %% setup
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %% [markdown]
# **Step 1:** Run the code below as-is to try the task without any extra
# context. How does the model do? Can you run the function? Does it give you the
# weather? Does it know enough about the NWS Python package to complete the
# task?
#
# **Step 2:** Now, let's add some context. Head over to the GitHub Repo for NWS
# (link in `docs.py.md`). Copy the project description from the `README.me` and
# paste it into `docs.py.md`.
#
# **Step 3:** Uncomment the extra lines to include these docs in the prompt and
# try again.

# %% task
chat = chatlas.ChatAuto("anthropic/claude-3-5-sonnet-20241022")

chat.chat(
    ## Extra context from package docs
    # here("_exercises/15_coding-assistant/docs.py.md").read_text(),
    ## Task prompt
    "Write a simple function that takes latitude and longitude as inputs "
    "and returns the weather forecast for that location using the NWS "
    "package. Keep the function concise and simple and don't include error "
    "handling or data re-formatting. Include a short docstring, including "
    "including examples for NYC and Atlanta, GA.",
)


# %% [markdown]
# Put the result from the model in code block below to try it out.

# %% results
import NWS as weather
# ...
