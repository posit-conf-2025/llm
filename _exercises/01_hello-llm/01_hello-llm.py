# %% [markdown]
# In this workshop, we'll be using
# [chatlas](https://posit-dev.github.io/chatlas) to interact with large language
# models (LLMs) like OpenAI's GPT and Anthropic's Claude.

# %%
import chatlas

# %% [markdown]
# To load the API keys for these services, we'll use the the `dotenv` package to
# load them from the `.env` file in the root of this project.
# %%
import dotenv

dotenv.load_dotenv()

# %% [markdown]
# ## OpenAI

# %%
chat_gpt = chatlas.ChatOpenAI()
chat_gpt.chat(
    "I'm at posit::conf(2025) to learn about programming with LLMs and ellmer! "
    "Write a short social media post for me."
)


# %% [markdown]
# ## Anthropic

# %%
chat_claude = chatlas.ChatAnthropic()
chat_claude.chat(
    "I'm at posit::conf(2025) to learn about programming with LLMs and ellmer!",
    "Write a short poem to celebrate.",
)
