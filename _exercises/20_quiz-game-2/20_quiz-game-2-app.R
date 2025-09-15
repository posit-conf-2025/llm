library(shiny)
library(bslib)
library(beepr)
library(ellmer)
library(shinychat)

# Tools ------------------------------------------------------------------------

#' Plays a sound effect.
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

  glue::glue("The '{sound}' sound was played.")
}

# STEP 1: Create a tool definition with documentation ----
# Remember: you're teaching the LLM how and when to use this function.
tool_play_sound <- tool(
  play_sound,
  description = "____",
  arguments = list(
    ____ = type_____()
  )
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

  # STEP 2: Register the tool with the chat client ----
  client$____(____)

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
