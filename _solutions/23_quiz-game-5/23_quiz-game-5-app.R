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
      here::here("_solutions/14_quiz-game-1/prompt.md")
    ) |>
      paste(
        "\n\nAfter every question, use the 'Update Score' tool to keep track of the user's score.",
        "Be sure to call the tool after you have graded the user's final answer to the question."
      )
  )

  output$tbl_scores <- renderTable(scores())
  output$txt_correct <- renderText(sum(scores()$is_correct, na.rm = TRUE))
  output$txt_incorrect <- renderText(sum(!scores()$is_correct, na.rm = TRUE))

  scores <- reactiveVal(
    data.frame(
      theme = character(),
      question = character(),
      answer = character(),
      your_answer = character(),
      is_correct = logical()
    )
  )

  update_score <- function(theme, question, answer, your_answer, is_correct) {
    the_scores <- isolate(scores())

    new_score <- data.frame(theme = theme, question = question, answer = answer, your_answer = your_answer, is_correct = is_correct) # fmt: skip
    the_scores <- rbind(the_scores, new_score)
    scores(the_scores)

    correct <- sum(the_scores$answer == the_scores$your_answer)
    list(correct = correct, incorrect = nrow(the_scores) - correct)
  }

  client$register_tool(tool(
    update_score,
    description = paste(
      "Add a correct or incorrect answer to the score tally.",
      "Call this tool after you've graded the user's answer to a question."
    ),
    arguments = list(
      theme = type_string("The theme of the round."),
      question = type_string("The quiz question that was asked."),
      answer = type_string("The correct answer to the question."),
      your_answer = type_string("The user's answer to the question."),
      is_correct = type_boolean("Whether the user's answer was correct.")
    ),
    annotations = tool_annotations(
      title = "Update Score",
      icon = fontawesome::fa_i("circle-plus")
    )
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
