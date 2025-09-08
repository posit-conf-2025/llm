# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %%
chat = chatlas.ChatAnthropic(
    model="claude-3-7-sonnet-20250219",
    system_prompt=here("_solutions/14_quiz-game-1/prompt.md").read_text(),
)

_ = chat.chat("Begin the quiz game.", echo="none")
chat.set_turns(chat.get_turns()[-1:])  # Keep only the assistant's greeting

# %%
chat.app()
