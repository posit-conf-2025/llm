from pathlib import Path
from typing import Literal

import chatlas
import dotenv
import faicons
from playsound3 import playsound
from pyhere import here
from shiny import App, reactive, ui

dotenv.load_dotenv()

# Tools ------------------------------------------------------------------------
SoundChoice = Literal["correct", "incorrect", "new-round", "you-win"]

sound_map: dict[SoundChoice, Path] = {
    "correct": here("data/sounds/smb_coin.wav"),
    "incorrect": here("data/sounds/wilhelm.wav"),
    "new-round": here("data/sounds/victory_fanfare_mono.wav"),
    "you-win": here("data/sounds/smb_stage_clear.wav"),
}


def play_sound(sound: SoundChoice = "correct") -> str:
    """
    Plays a sound effect.

    Parameters
    ----------
    sound: Which sound effect to play: "correct", "incorrect", "new-round" or
           "you-win". Play the "new-round" sound after the user picks a theme
           for the round. Play the "correct" and "incorrect" sounds when the
           user answers a question correctly or incorrectly, respectively. And
           play the "you-win" sound at the end of a round of questions.

    Returns
    -------
    A confirmation that the sound was played.
    """
    if sound not in sound_map.keys():
        raise ValueError(
            f"sound must be one of {sorted(sound_map.keys())}; got {sound!r}"
        )

    playsound(sound_map[sound])

    return f"The '{sound}' sound was played."


# UI ---------------------------------------------------------------------------

app_ui = ui.page_fillable(
    ui.chat_ui("chat"),
)


def server(input, output, session):
    # Recall: We set up the Chat UI server logic and the chat client in the
    # server function so that each user session gets its own chat history.
    chat_ui = ui.Chat(id="chat")
    client = chatlas.ChatAnthropic(
        model="claude-3-7-sonnet-20250219",
        # Use your quiz game system prompt, or switch to _solutions to use ours
        system_prompt=here("_exercises/14_quiz-game-1/prompt.md").read_text(),
    )

    client.register_tool(
        play_sound,
        # STEP 1: Add nice title and icon for the tool button ----
        annotations={
            "____": "____",
            "extra": {
                # Pick a Font Awesome icon from the "free" choices
                # https://fontawesome.com/search?q=speaker&ic=free&o=r
                "____": faicons.icon_svg("____"),
            },
        },
    )

    @chat_ui.on_user_submit
    async def handle_user_input(user_input: str):
        response = await client.stream_async(user_input, content="all")
        await chat_ui.append_message_stream(response)

    @reactive.effect
    def _():
        # Note: This block starts the game when the app launches
        chat_ui.update_user_input(value="Let's play the quiz game!", submit=True)


app = App(app_ui, server)
