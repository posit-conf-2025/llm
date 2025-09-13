import chatlas
import dotenv
from shiny import App, ui

dotenv.load_dotenv()

system_prompt = """
We are playing a word guessing game. You are going to think of a random word.
When you do, write it in an HTML comment so that you can remember it, but the
user can't see it.

Give the user an initial clue and then only answer their questions with yes or
no. When they win, use lots of emojis.
"""

app_ui = ui.page_fillable(
    ui.chat_ui("chat", placeholder="""Say "Let's play" to get started!""")
)


def server(input, output, session):
    client = chatlas.ChatOpenAI(system_prompt=system_prompt)
    chat = ui.Chat("chat")

    @chat.on_user_submit
    async def _(user_input: str):
        response = await client.stream_async(user_input)
        await chat.append_message_stream(response)


app = App(app_ui, server)
