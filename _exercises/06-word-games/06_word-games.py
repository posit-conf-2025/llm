import chatlas
import random
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

words_file = Path(__file__).parent / 'words.txt'
words = words_file.read_text().strip().split('\n')

chat = chatlas.ChatOpenAI(
  system_prompt=f"""
We are playing a word guessing game.
Here's the secret words: {random.sample(words, 1)}.
Give the user an initial clue and then only answer their questions with yes or no.
When they win, use lots of emojis.
  """
)

# Start the chat and say "Let's play"
chat.console()