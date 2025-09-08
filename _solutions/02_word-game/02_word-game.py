import chatlas
import dotenv

dotenv.load_dotenv()

chat = chatlas.ChatOpenAI(
    system_prompt="We are playing a word guessing game. "
    "At each turn, you guess the word and tell us what it is."
)
chat.chat("In British English, guess the word for a person who lives next door.")
chat.chat("What helps a car move smoothly down the road?")

# Compare with...
chat = chatlas.ChatOpenAI()
chat.chat("What helps a car move smoothly down the road?")
