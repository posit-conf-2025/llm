# %%
import dotenv
from chatlas import ChatAuto

dotenv.load_dotenv()

# %% [markdown]
# List models by calling the `list_models` method on a `Chat` instance.

# %%
ChatAuto(____).list_models()

# %% [markdown]
# You can also load the models into a Polars DataFrame for easier viewing.
# Use this block to list OpenAI and Anthropic models.

# %%
import polars as pl

models = ChatAuto("____").list_models()
models = pl.DataFrame(models)
models

# %% [markdown]
# Now try sending the same prompt to different models to compare the responses.

# %%
prompt = "Write a  recipe for an easy weeknight dinner my kids would like."

ChatAuto("____").chat(prompt)
ChatAuto("____").chat(prompt)

# %% [markdown]
# Bonus: local models?
#
# If you have local models installed, try them out with Ollama. Note that you
# have to give a model name to list models, but the model name can be anything.

# %%
ChatAuto("ollama/any-model-name").list_models()
ChatAuto("ollama/gemma3:4b").chat(prompt)

# %% [markdown]
# Bonus: Rewrite your `ChatAuto()` calls to use the direct provider functions.

# %%
from chatlas import ChatAnthropic, ChatOpenAI

Chat____(____)
Chat____(____)
