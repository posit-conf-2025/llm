library(shiny)
library(bslib)
library(ellmer)
library(shinychat)

# UI ---------------------------------------------------------------------------

ui <- page_sidebar(
  title = "Quiz Game 5",
  sidebar = sidebar(
    position = "right",
    fillable = TRUE,
    width = 400,
    value_box(
      "Correct Answers",
      textOutput("txt_correct"),
      showcase = fontawesome::fa_i("circle-check"),
      theme = "success"
    ),
    value_box(
      "Incorrect Answers",
      textOutput("txt_incorrect"),
      showcase = fontawesome::fa_i("circle-xmark"),
      theme = "danger"
    )
  ),
  navset_card_tab(
    nav_panel("Quiz Game", chat_mod_ui("chat")),
    nav_panel("Your Answers", tableOutput("tbl_scores"))
  )
)

# Server -----------------------------------------------------------------------

server <- function(input, output, session) {
  client <- chat(
    "anthropic/claude-3-7-sonnet-20250219",
    system_prompt = interpolate_file(
      # Use your quiz game system prompt, or switch to `_solutions` to use ours
      here::here("_exercises/14_quiz-game-1/prompt.md")
    ) |>
      # STEP 1: Add instructions about when to use the score-keeping tool ----
      paste(
        "\n\nAfter every question, use the 'Update Score' tool to... ____"
      )
  )

  scores <- reactiveVal(
    data.frame(
      theme = character(),
      question = character(),
      answer = character(),
      your_answer = character(),
      is_correct = logical()
    )
  )

  output$tbl_scores <- renderTable(scores())
  output$txt_correct <- renderText(sum(scores()$is_correct, na.rm = TRUE))
  output$txt_incorrect <- renderText(sum(!scores()$is_correct, na.rm = TRUE))

  # STEP 2: Implement the score-keeping tool ----
  # When the tool is called, add a new row to the `scores()` reactive data frame
  update_score <- function(theme, question, answer, your_answer, is_correct) {
    the_scores <- isolate(scores())
    the_scores <- rbind(
      the_scores,
      ____
    )
    # Now that we have new scores, update the `scores()` reactive value
    scores(the_scores)
    correct <- sum(the_scores$answer == the_scores$your_answer)
    # And return the current tally of correct and incorrect answers
    list(correct = correct, incorrect = nrow(the_scores) - correct)
  }

  client$register_tool(tool(
    update_score,
    description = paste(
      "Add a correct or incorrect answer to the score tally.",
      "Call this tool after you've graded the user's answer to a question."
    ),
    # STEP 3: Complete the tool definition ----
    arguments = list(
      theme = ____("The theme of the round."),
      question = ____("The quiz question that was asked."),
      answer = ____("The correct answer to the question."),
      your_answer = ____("The user's answer to the question."),
      is_correct = ____("Whether the user's answer was correct.")
    ) #,
    ## STEP 4: Add tool annotations ----
    # annotations = tool_annotations(
    #   title = "____",
    #   # https://fontawesome.com/search?q=plus&ic=free&o=r
    #   ____ = fontawesome::fa_i("____")
    # )
  ))

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
