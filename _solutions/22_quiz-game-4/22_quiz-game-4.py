# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %%
from pathlib import Path
from typing import Any, Literal

from faicons import icon_svg
from playsound3 import playsound

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


# %%
chat = chatlas.ChatAnthropic(
    model="claude-3-7-sonnet-20250219",
    system_prompt=here("_solutions/14_quiz-game-1/prompt.md").read_text(),
)

# %%
chat.register_tool(
    play_sound,
    annotations={"title": "Play Sound Effect"},
)

_ = chat.chat("Begin the quiz game.", echo="none")
chat.set_turns(chat.get_turns()[-1:])  # Keep only the assistant's greeting

# %%
chat.app()
