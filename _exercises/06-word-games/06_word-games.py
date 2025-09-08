# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

words_file = here() / "_exercises" / "06-word-games" / "words.txt"
words = words_file.read_text().strip().split("\n")

# %%
chat = chatlas.ChatOpenAI(
    system_prompt=f"""
We are playing a word guessing game.
Here's the secret words: {random.sample(words, 1)}.
Give the user an initial riddle and then only answer their questions with yes or no.
When they win, use lots of emojis.
  """
)

# %%
print('Start the chat by saying "Let\'s play"')
chat.console()
