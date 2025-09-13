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
    # Step 1: Add the chat UI component
)


def server(input, output, session):
    # Step 2: Initialize the chat client with the system prompt
    client = ____
    # Step 3: Add the chat UI server setup
    chat = ____

    @chat.on_user_submit
    async def _(user_input: str):
        # Step 4: Submit the user input to the client to get a streaming response
        response = await client.____
        # Step 5: Append the streaming response to the chat UI
        await chat.____(response)


app = App(app_ui, server)
