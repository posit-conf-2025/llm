# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %%
from typing import Literal

from playsound3 import playsound

SoundChoice = Literal["correct", "incorrect", "you-win"]


def play_sound(sound: SoundChoice = "correct") -> str:
    """
    Plays a sound effect.

    Parameters
    ----------
    sound: Which sound effect to play: "correct", "incorrect", or "you-win".

    Returns
    -------
    A confirmation that the sound was played.
    """
    allowed = {"correct", "incorrect", "you-win"}
    if sound not in allowed:
        raise ValueError(f"sound must be one of {sorted(allowed)}; got {sound!r}")

    # Map choices to audio file paths. Update these to valid files on your machine.
    sound_map = {
        "correct": here("data/sounds/smb_coin.wav"),
        "incorrect": here("data/sounds/wilhelm.wav"),
        "you-win": here("data/sounds/smb_stage_clear.wav"),
    }

    playsound(sound_map[sound])

    return f"The '{sound}' sound was played."


# %%
chat = chatlas.ChatAnthropic(
    model="claude-3-7-sonnet-20250219",
    system_prompt=here("_solutions/14_quiz-game-1/prompt.md").read_text(),
)

# %%
from pathlib import Path

import bsicons
from htmltools import HTML

icon = Path(bsicons.get_icon_path("volume-up-fill"))

chat.register_tool(
    play_sound,
    annotations={
        "title": "Play Sound Effect",
        "extra": {
            "icon": HTML(icon.read_text()),
        }
    }
)

_ = chat.chat("Begin the quiz game.", echo="none")
chat.set_turns(chat.get_turns()[-1:])  # Keep only the assistant's greeting

# %%
chat.app()
