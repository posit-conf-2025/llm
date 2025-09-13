# %%
import chatlas
import dotenv

dotenv.load_dotenv()


# %% [markdown]
# Your job: work with a chatbot to roast Hadley Wickham.

# %%
chat = chatlas.ChatOpenAI()

# %% [markdown]
# Converse with the chatbot in your console.

# %%
chat.console()

# %% [markdown]
# After a bit, exit the chat and try chatting in a Shiny app.

# %%
chat.app()
