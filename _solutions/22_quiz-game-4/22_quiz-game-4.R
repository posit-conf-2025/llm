library(beepr)
library(ellmer)

#' Plays a sound effect.
#'
#' @param sound Which sound effect to play: `"correct"`, `"incorrect"`,
#'   `"new-round"`, or `"you-win"`.
#' @returns A confirmation that the sound was played.
play_sound <- function(
  sound = c("correct", "incorrect", "new-round", "you-win")
) {
  sound <- match.arg(sound)

  switch(
    sound,
    correct = beepr::beep("coin"),
    incorrect = beepr::beep("wilhelm"),
    "new-round" = beepr::beep("fanfare"),
    "you-win" = beepr::beep("complete")
  )

  icon <- switch(
    sound,
    correct = fontawesome::fa_i(
      "circle-check",
      class = "text-success",
      prefer_type = "solid"
    ),
    incorrect = fontawesome::fa_i(
      "circle-xmark",
      class = "text-danger",
      prefer_type = "solid"
    ),
    "new-round" = fontawesome::fa_i(
      "circle-play",
      class = "text-primary",
      prefer_type = "solid"
    ),
    "you-win" = fontawesome::fa_i("medal", class = "text-warning")
  )

  title <- switch(
    sound,
    correct = "That's right!",
    incorrect = "Oops, not quite.",
    "new-round" = "Let's goooooo!",
    "you-win" = "You Win!"
  )

  ContentToolResult(
    glue::glue("The '{sound}' sound was played."),
    extra = list(
      display = list(
        title = title,
        icon = icon
      )
    )
  )
}

tool_play_sound <- tool(
  play_sound,
  description = "Play a sound effect",
  arguments = list(
    sound = type_enum(
      c("correct", "incorrect", "new-round", "you-win"),
      description = paste(
        "Which sound effect to play.",
        "Play 'new-round' after the user picks a theme for the round.",
        "Play 'correct' or 'incorrect' after the user answers a question.",
        "Play 'you-win' at the end of a round of questions."
      )
    )
  ),
  annotations = tool_annotations(title = "Play Sound Effect")
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
