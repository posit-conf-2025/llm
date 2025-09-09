from pathlib import Path
from typing import Any, Literal

import chatlas
import dotenv
from faicons import icon_svg
from playsound3 import playsound
from pyhere import here
from shiny import App, reactive, render, ui
from shiny.reactive import isolate

dotenv.load_dotenv()

# Tools ------------------------------------------------------------------------
SoundChoice = Literal["correct", "incorrect", "new-round", "you-win"]

sound_map: dict[SoundChoice, Path] = {
    "correct": here("data/sounds/smb_coin.wav"),
    "incorrect": here("data/sounds/wilhelm.wav"),
    "new-round": here("data/sounds/victory_fanfare_mono.wav"),
    "you-win": here("data/sounds/smb_stage_clear.wav"),
}

icon_map: dict[SoundChoice, Any] = {
    "correct": icon_svg("circle-check", fill="var(--bs-success)"),
    "incorrect": icon_svg("circle-xmark", fill="var(--bs-danger)"),
    "new-round": icon_svg("circle-play", fill="var(--bs-primary)"),
    "you-win": icon_svg("trophy", fill="var(--bs-warning)"),
}

title_map: dict[SoundChoice, str] = {
    "correct": "That's right!",
    "incorrect": "Oops, not quite.",
    "new-round": "Let's goooooooo!",
    "you-win": "You Win",
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

    return chatlas.ContentToolResult(
        value=f"The '{sound}' sound was played.",
        extra={
            "display": {
                "title": title_map[sound],
                "icon": icon_map[sound],
            }
        },
    )


# UI ---------------------------------------------------------------------------

app_ui = ui.page_sidebar(
    ui.sidebar(
        ui.value_box(
            "Correct Answers",
            ui.output_text("correct"),
            showcase=icon_svg("circle-check"),
            theme="success",
        ),
        ui.value_box(
            "Incorrect Answers",
            ui.output_text("incorrect"),
            showcase=icon_svg("circle-xmark"),
            theme="danger",
        ),
        position="right",
        fillable=True,
        width=400,
    ),
    ui.card(
        ui.card_header("Quiz Game"),
        ui.chat_ui("chat"),
    ),
    title="Quiz Game 5",
    fillable=True,
)


def server(input, output, session):
    chat_ui = ui.Chat(id="chat")

    # Set up the chat instance
    client = chatlas.ChatAnthropic(
        model="claude-3-7-sonnet-20250219",
        system_prompt=here("_solutions/14_quiz-game-1/prompt.md").read_text(),
    )
    client.register_tool(
        play_sound,
        annotations={"title": "Play Sound Effect"},
    )

    score_correct = reactive.Value(0)
    score_incorrect = reactive.Value(0)

    @render.text
    def correct():
        return score_correct()

    @render.text
    def incorrect():
        return score_incorrect()

    def update_score(is_correct: bool = True):
        """
        Add a correct or incorrect answer to the score. Call this tool after the
        user answers a question.
        """
        val_correct = isolate(score_correct()) + 1 if is_correct else 0
        val_incorrect = isolate(score_incorrect()) + 0 if is_correct else 1
        score_correct.set(val_correct)
        score_incorrect.set(val_incorrect)
        return {"correct": val_correct, "incorrect": val_incorrect}

    client.register_tool(
        update_score,
        annotations={
            "title": "Update Score",
            "extra": {"icon": icon_svg("circle-plus")},
        },
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
