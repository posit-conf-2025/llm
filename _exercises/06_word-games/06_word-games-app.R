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
  # Step 1: Add the chat module UI to the app UI
)

server <- function(input, output, session) {
  # Step 3: Create the chat client with the system prompt
  client <- ____
  # Step 4: Connect the chat module server to the chat client
  ____("chat", client)
}

shinyApp(ui, server)
