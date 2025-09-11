library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(leaflet)

theme_set(theme_minimal(14))
ggplot2::update_geom_defaults("bar", list(fill = "#007BC2"))
ggplot2::update_geom_defaults("boxplot", list(colour = "#007BC2"))

# Load and prepare data
airbnb_data <-
  read.csv(here::here("data/airbnb-asheville.csv")) |>
  filter(!is.na(price)) |>
  mutate(occupancy_pct = (365 - availability_365) / 365)

# UI --------------------------------------------------------------------------
ui <- page_sidebar(
  title = "Asheville Airbnb Dashboard",
  class = "bslib-page-dashboard",
  sidebar = sidebar(
    # Sidebar ----
    checkboxGroupInput(
      "room_type",
      "Room Type",
      choices = unique(airbnb_data$room_type),
      selected = unique(airbnb_data$room_type)
    ),
    selectInput(
      "neighborhood",
      "Neighborhood",
      choices = c("All" = "", unique(airbnb_data$neighborhood)),
      multiple = TRUE
    ),
    sliderInput(
      "price",
      "Price Range",
      min = 0,
      max = 7000,
      value = c(0, 7000),
      step = 50,
      ticks = FALSE,
      pre = "$"
    )
  ),
  # Value boxes ----
  layout_columns(
    fill = FALSE,
    value_box(
      title = "Number of Listings",
      value = textOutput("num_listings"),
      showcase = fontawesome::fa_i("home")
    ),
    value_box(
      title = "Average Price per Night",
      value = textOutput("avg_price"),
      showcase = fontawesome::fa_i("dollar-sign")
    ),
    value_box(
      title = "Average Occupancy",
      value = textOutput("avg_occupancy"),
      showcase = fontawesome::fa_i("calendar-check")
    )
  ),
  # Cards ----
  layout_columns(
    card(
      full_screen = TRUE,
      card_body(
        padding = 0,
        leafletOutput("listings_map")
      )
    ),
    layout_columns(
      col_widths = 12,
      card(
        full_screen = TRUE,
        card_header("Room Types"),
        plotOutput("room_type_plot")
      ),
      card(
        full_screen = TRUE,
        card_header("Availability by Room Type"),
        plotOutput("availability_plot")
      )
    )
  )
)

# Server ----------------------------------------------------------------------

server <- function(input, output, session) {
  # Reactive for filtered data
  filtered_data <- reactive({
    data <- airbnb_data
    if (length(input$room_type)) {
      data <- data |> filter(room_type %in% input$room_type)
    }
    if (any(nzchar(input$neighborhood))) {
      data <- data |> filter(neighborhood %in% input$neighborhood)
    }
    data |> filter(price >= input$price[1] & price <= input$price[2])
  })

  # Value boxes
  output$num_listings <- renderText({
    scales::comma(nrow(filtered_data()))
  })

  output$avg_price <- renderText({
    validate(need(nrow(filtered_data()) > 0, "N/A"))
    scales::dollar(mean(filtered_data()$price), accuracy = 1)
  })

  output$avg_occupancy <- renderText({
    validate(need(nrow(filtered_data()) > 0, "N/A"))
    scales::percent(mean(filtered_data()$occupancy_pct))
  })

  # Plots
  output$room_type_plot <- renderPlot({
    validate(need(nrow(filtered_data()) > 0, "No listings available."))

    filtered_data() |>
      count(room_type) |>
      mutate(room_type = forcats::fct_reorder(room_type, n)) |>
      ggplot(aes(x = n, y = room_type)) +
      geom_col() +
      labs(x = "Number of Listings", y = NULL)
  })

  output$availability_plot <- renderPlot({
    validate(need(nrow(filtered_data()) > 0, "No listings available."))

    filtered_data() |>
      ggplot(aes(x = availability_365, y = room_type)) +
      geom_boxplot() +
      labs(x = "Availability (days/year)", y = NULL)
  })

  # Map
  output$listings_map <- renderLeaflet({
    validate(need(nrow(filtered_data()) > 0, "No listings available."))

    leaflet(filtered_data()) |>
      addTiles() |>
      # fmt: skip
      addMarkers(
        ~longitude,
        ~latitude,
        clusterOptions = markerClusterOptions(),
        popup = ~ paste0(
          "<strong>", name, "</strong><br>",
          "Price: ", scales::dollar(price), "<br>",
          "Room Type: ", room_type, "<br>",
          "Neighborhood: ", neighborhood, "<br>",
          "Owner: ", host_name, "<br>",
          "Reviews: ", scales::comma(number_of_reviews), "<br>",
          "Availability: ", availability_365, " days/year"
        )
      )
  })
}

shinyApp(ui, server)
