library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(leaflet)
library(ellmer)
library(querychat)
library(reactable)

theme_set(theme_minimal(14))
ggplot2::update_geom_defaults("bar", list(fill = "#007BC2"))
ggplot2::update_geom_defaults("boxplot", list(colour = "#007BC2"))

# Load and prepare data
airbnb_data <-
  read.csv(here::here("data/airbnb-asheville.csv")) |>
  filter(!is.na(price)) |>
  mutate(occupancy_pct = (365 - availability_365) / 365)

# Step 1: Set up querychat ----------
# Configure querychat. This is where you specify the dataset and can also
# override options like the greeting message, system prompt, model, etc.
airbnb_qc_config <- querychat_init(airbnb_data)

# UI --------------------------------------------------------------------------
ui <- page_sidebar(
  title = "Asheville Airbnb Dashboard",
  class = "bslib-page-dashboard",

  # Step 2: Replace sidebar ----
  # Replace the entire sidebar with querychat_sidebar("airbnb")
  sidebar = querychat_sidebar("airbnb"),

  if (exists("airbnb_qc_config")) {
    card(
      fill = FALSE,
      max_height = "400px",
      full_screen = TRUE,
      card_body(
        padding = 0,
        navset_card_underline(
          nav_spacer(),
          nav_panel(
            "SQL",
            icon = fontawesome::fa_i("terminal"),
            uiOutput("ui_sql")
          ),
          nav_panel(
            "Table",
            icon = fontawesome::fa_i("table"),
            reactableOutput("table")
          )
        )
      )
    )
  },

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
    min_height = "400px",
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
  # Step 3: Set up querychat server ----
  # Create an `airbnb_qc` querychat object by calling `querychat_server()` with
  # the same ID and config from steps 2 and 1.
  airbnb_qc <- querychat_server("airbnb", airbnb_qc_config)

  # Step 4: Use the querychat-filtered data ----
  # Replace all of the logic inside of `filtered_data()` with
  # `airbnb_qc$df()`.
  filtered_data <- reactive({
    airbnb_qc$df()
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
          "Reviews: ", scales::comma(n_reviews), "<br>",
          "Availability: ", availability_365, " days/year"
        )
      )
  })

  # querychat outputs
  if (exists("airbnb_qc")) {
    output$ui_sql <- renderUI({
      sql <- airbnb_qc$sql()
      if (!isTruthy(sql)) {
        sql <- "SELECT * FROM aibnb_data"
      }
      HTML(paste0("<pre><code>", sql, "</code></pre>"))
    })

    output$table <- renderReactable({
      reactable(
        airbnb_qc$df(),
        columns = list(
          name = colDef(minWidth = 200),
          price = colDef(
            align = "right",
            format = colFormat(prefix = "$", separators = TRUE, digits = 0)
          ),
          room_type = colDef(),
          neighborhood = colDef(),
          occupancy_pct = colDef(
            format = colFormat(percent = TRUE, digits = 1)
          ),
          description = colDef(show = FALSE),
          amenities = colDef(show = FALSE),
          url_picture = colDef(show = FALSE),
          url_listing = colDef(show = FALSE)
        ),
        defaultPageSize = 20,
        highlight = TRUE,
        bordered = TRUE,
        striped = TRUE,
        showPageSizeOptions = TRUE,
        details = function(index) {
          row <- airbnb_qc$df()[index, ]
          htmltools::div(
            style = "padding: 16px;",
            htmltools::tags$strong("Description:"),
            htmltools::tags$p(row$description),
            htmltools::tags$strong("Amenities:"),
            htmltools::tags$p(row$amenities)
          )
        }
      )
    })
  }
}

shinyApp(ui, server)
