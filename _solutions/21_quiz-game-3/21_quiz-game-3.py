# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %%
from typing import Literal

from playsound3 import playsound

SoundChoice = Literal["correct", "incorrect", "new-round", "you-win"]

sound_map: dict[SoundChoice, "Path"] = {
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


# %%
chat = chatlas.ChatAnthropic(
    model="claude-3-7-sonnet-20250219",
    system_prompt=here("_solutions/14_quiz-game-1/prompt.md").read_text(),
)

# %%
from pathlib import Path

import faicons
from htmltools import HTML

chat.register_tool(
    play_sound,
    annotations={
        "title": "Play Sound Effect",
        "extra": {
            "icon": faicons.icon_svg("volume-high"),
        },
    },
)

_ = chat.chat("Begin the quiz game.", echo="none")
chat.set_turns(chat.get_turns()[-1:])  # Keep only the assistant's greeting

# %%
chat.app()
