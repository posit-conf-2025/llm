library(shiny)
library(bslib)
library(beepr)
library(ellmer)
library(shinychat)

# Tools ------------------------------------------------------------------------

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
    "you-win" = beepr::beep("mario")
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


# UI ---------------------------------------------------------------------------

ui <- page_fillable(
  chat_mod_ui("chat")
)

# Server -----------------------------------------------------------------------

server <- function(input, output, session) {
  client <- chat(
    "anthropic/claude-3-7-sonnet-20250219",
    system_prompt = interpolate_file(
      # Use your quiz game system prompt, or switch to `_solutions` to use ours
      here::here("_solutions/14_quiz-game-1/prompt.md")
    )
  )

  client$register_tool(tool_play_sound)

  chat <- chat_mod_server("chat", client)

  observe({
    # Note: This block starts the game when the app launches
    chat$update_user_input(
      value = "Let's play the quiz game!",
      submit = TRUE
    )
  })
}

shinyApp(ui, server)
