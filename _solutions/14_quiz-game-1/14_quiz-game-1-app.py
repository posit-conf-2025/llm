import chatlas
import dotenv
from pyhere import here
from shiny import App, reactive, ui

dotenv.load_dotenv()


# UI ---------------------------------------------------------------------------

app_ui = ui.page_fillable(
    ui.chat_ui("chat"),
)


def server(input, output, session):
    chat_ui = ui.Chat(id="chat")

    # Set up the chat instance
    client = chatlas.ChatAnthropic(
        model="claude-3-7-sonnet-20250219",
        system_prompt=here("_solutions/14_quiz-game-1/prompt.md").read_text(),
    )

    @chat_ui.on_user_submit
    async def handle_user_input(user_input: str):
        # Use `content="all"` to include tool calls in the response stream
        response = await client.stream_async(user_input, content="all")
        await chat_ui.append_message_stream(response)

    @reactive.effect
    def _():
        # Start the game when the app launches
        chat_ui.update_user_input(value="Let's play the quiz game!", submit=True)


app = App(app_ui, server)
