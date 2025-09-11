# 🚨 Open app in a browser!

library(shiny)
library(bslib)
library(ellmer)
library(shinychat)

system_prompt <- r"---(
The user can look up the weather for you.
If you need the weather forecast, write a message containing only the text `get_weather(zip_code)`, replacing `zip_code` with the actual zip code.
You may need to guess the zip code.

EXAMPLE

User: What should I wear today in Hollywood?

Assistant: `get_weather(90210)`

User: ...provides weather forecast...
)---"

ui <- page_navbar(
  title = "Human-in-the-loop",
  sidebar = sidebar(
    div(
      style = "font-size: 0.9em",
      p("System Prompt", class = "fw-bold"),
      markdown(system_prompt),
    ),
    p(
      a(href = "https://weather.gov", target = "_blank", "weather.gov"),
    )
  ),
  nav_spacer(),
  nav_panel(
    "Chat",
    icon = icon("robot"),
    chat_mod_ui("chat")
  ),
  nav_panel(
    "Weather",
    icon = icon("cloud"),
    tags$iframe(
      id = "weather-iframe",
      src = "https://weather.gov",
      style = "border:none;",
      height = "800px",
      width = "100%"
    )
  )
)

server <- function(input, output, session) {
  client <- chat_openai(
    system_prompt = system_prompt,
    model = "gpt-4.1-nano"
  )

  chat <- chat_mod_server("chat", client)
  observe({
    chat$update_user_input(
      "What should I wear to posit::conf() in Atlanta?"
    )
  })
}

shinyApp(ui, server)
