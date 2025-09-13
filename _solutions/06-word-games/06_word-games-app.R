library(shiny)
library(bslib)
library(ellmer)
library(shinychat)

system_prompt <- r"--(
We are playing a word guessing game. You are going to think of a random word.
When you do, write it in an HTML comment so that you can remember it, but the
user can't see it.

Give the user an initial clue and then only answer their questions with yes or
no. When they win, use lots of emojis.
)--"


ui <- page_fillable(
  chat_mod_ui("chat", placeholder = r"(Say "Let's play" to get started!)")
)

server <- function(input, output, session) {
  client <- chat_openai(system_prompt = system_prompt)
  chat_mod_server("chat", client)
}

shinyApp(ui, server)
