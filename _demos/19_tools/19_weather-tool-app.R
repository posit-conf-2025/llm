library(shiny)
library(bslib)
library(ellmer)
library(shinychat)
library(weathR)

get_weather <- tool(
  \(lat, lon) weathR::point_forecast(lat, lon),
  name = "get_weather",
  description = "Get forecast data for a specific latitude and longitude.",
  arguments = list(
    lat = type_number("Latitude of the location."),
    lon = type_number("Longitude of the location.")
  )
)

ui <- page_fillable(
  chat_mod_ui("chat")
)

server <- function(input, output, session) {
  client <- ellmer::chat("openai/gpt-4.1-nano")
  client$register_tool(get_weather)

  chat_mod_server("chat", client)
}

shinyApp(ui, server)
