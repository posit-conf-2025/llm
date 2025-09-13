# %%
import chatlas
import dotenv

dotenv.load_dotenv()

# %% [markdown]
# ## Ley's play a word game!
#
# Set up a `chat` with a system prompt:
#
# > You are playing a word guessing game. At each turn, guess the word and tell
# > us what it is.

# %%
chat = chatlas.____(____="")

# %%
# Ask the first question:
____("In British English, guess the word for a person who lives next door.")

# %%
# Ask the second question:
____("What helps a car move smoothly down the road?")

# %% [markdown]
# Crate a new, empty chat and ask the second question again, by itself.
#
# How do the responses differ? Why?

# %%
chat2 = chatlas.____()
chat2.____("What helps a car move smoothly down the road?")
