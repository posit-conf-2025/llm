library(beepr)
library(ellmer)

#' Plays a sound effect.
#'
#' @param sound Which sound effect to play: `"correct"`, `"incorrect", or
#'   `"you-win"`.
#' @returns A confirmation that the sound was played.
play_sound <- function(sound = c("correct", "incorrect", "you-win")) {
  sound <- match.arg(sound)
  if (sound == "correct") {
    beepr::beep("coin")
  } else if (sound == "incorrect") {
    beepr::beep("wilhelm")
  } else if (sound == "you-win") {
    beepr::beep("fanfare")
  }
  glue::glue("The '{sound}' sound was played.")
}

tool_play_sound <- tool(
  play_sound,
  description = "Play a sound effect",
  arguments = list(
    sound = type_string(
      "The sound to play. Must be one of 'correct', 'incorrect', or 'you-win'.",
      required = FALSE
    )
  ),
  annotations = tool_annotations(
    title = "Play Sound Effect",
    icon = bsicons::bs_icon("volume-up-fill")
  )
)

chat <- chat(
  "anthropic/claude-3-7-sonnet-20250219",
  system_prompt = interpolate_file(
    # Replace `_solutions` with `_exercises` to get your own prompt from before
    here::here("_solutions/14_quiz-game-1/prompt.md")
  )
)

chat$register_tool(tool_play_sound)

. <- chat$chat("Begin", echo = FALSE) # get LLM to give us the greeting
chat$set_turns(chat$get_turns()[-1]) # remove first "Begin" message
live_browser(chat, quiet = TRUE)
