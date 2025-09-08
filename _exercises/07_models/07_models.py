# %%
import dotenv
from chatlas import ChatAuto

dotenv.load_dotenv()

# %% [markdown]
# List models by calling the `list_models` method on a `Chat` instance.

# %%
ChatAuto("openai").list_models()

# %% [markdown]
# You can also load the models into a Polars DataFrame for easier viewing.
# Try it out with different providers: `"anthropic"`, `"ollama/gemma3"`.

# %%
import polars as pl

models = ChatAuto("openai").list_models()
models = pl.DataFrame(models)
models

# %% [markdown]
# Now try sending the same prompt to different models to compare the responses.

# %%
prompt = "Write a  recipe for an easy weeknight dinner my kids would like."

ChatAuto("openai/gpt-5").chat(prompt)
ChatAuto("anthropic/claude-3-7-sonnet-20250219").chat(prompt)

# %%
# If you have local models installed, try them out with Ollama.
ChatAuto("ollama/gemma3:4b").chat(prompt)

# %% [markdown]
# Instead of `ChatAuto()`, you can also use the direct provider functions:

# %%
from chatlas import ChatAnthropic, ChatOllama, ChatOpenAI

ChatOpenAI(model="gpt-5")
ChatAnthropic(model="claude-3-7-sonnet-20250219")
ChatOllama(model="gemma3:4b")
