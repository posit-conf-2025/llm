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


# UI ---------------------------------------------------------------------------

ui <- page_sidebar(
  title = "Quiz Game 5",
  sidebar = sidebar(
    position = "right",
    fillable = TRUE,
    width = 400,
    value_box(
      "Correct Answers",
      textOutput("correct"),
      showcase = fontawesome::fa_i("circle-check"),
      theme = "success"
    ),
    value_box(
      "Incorrect Answers",
      textOutput("incorrect"),
      showcase = fontawesome::fa_i("circle-xmark"),
      theme = "danger"
    )
  ),
  card(
    card_header("Quiz Game"),
    chat_mod_ui("chat")
  )
)

# Server -----------------------------------------------------------------------

server <- function(input, output, session) {
  client <- chat(
    "anthropic/claude-3-7-sonnet-20250219",
    system_prompt = interpolate_file(
      # Replace `_solutions` with `_exercises` to get your own prompt from before
      here::here("_solutions/14_quiz-game-1/prompt.md")
    )
  )

  client$register_tool(tool_play_sound)

  correct <- reactiveVal(0)
  incorrect <- reactiveVal(0)
  output$correct <- renderText(correct())
  output$incorrect <- renderText(incorrect())

  client$register_tool(tool(
    function(is_correct) {
      correct <- isolate(correct()) + ifelse(is_correct, 1, 0)
      incorrect <- isolate(incorrect()) + ifelse(is_correct, 0, 1)
      # Update reactive values
      correct(correct)
      incorrect(incorrect)
      # Report score back to the model
      list(correct = correct, incorrect = incorrect)
    },
    name = "update_score",
    description = paste(
      "Add a correct or incorrect answer to the score tally.",
      "Call this tool after the user answers a question."
    ),
    arguments = list(
      is_correct = type_boolean(
        "TRUE if the user answered correctly, FALSE otherwise"
      )
    ),
    annotations = tool_annotations(
      title = "Update Score",
      icon = fontawesome::fa_i("circle-plus")
    )
  ))

  chat <- chat_mod_server("chat", client)

  observe({
    # Start the game when the app launches
    chat$update_user_input(
      value = "Let's play the quiz game!",
      submit = TRUE
    )
  })
}

shinyApp(ui, server)
