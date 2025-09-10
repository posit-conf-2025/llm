library(shiny)
library(bslib)
library(purrr)
library(jsonlite)

recipes <-
  here::here("data/recipes/recipes.json") |>
  fromJSON(simplifyVector = TRUE, simplifyDataFrame = FALSE)


ui_ingredients <- function(ingredients) {
  items <- purrr::map(ingredients, function(ingredient) {
    id <- paste0("ingredient-", gsub(" ", "-", tolower(ingredient$name)))

    tags$li(
      tags$input(
        class = "form-check-input",
        id = id,
        type = "checkbox",
        tags$label(
          class = "form-check-label ms-2",
          `for` = id,
          ingredient$quantity,
          if (!is.null(ingredient$unit)) ingredient$unit,
          tags$strong(ingredient$name),
          if (!is.null(ingredient$notes) && ingredient$notes != "") {
            paste0(" (", ingredient$notes, ")")
          }
        )
      )
    )
  })

  tags$ul(
    items,
    style = css(
      list_style = "none",
      padding = "0",
      margin = "0",
      display = "flex",
      flex_direction = "column",
      gap = "8px"
    )
  )
}

ui_instructions <- function(instructions) {
  items <- purrr::map(instructions, tags$li)
  tags$ol(items)
}

ui_recipe <- function(r) {
  card(
    card_header(r$title, class = "text-bg-dark"),
    card(
      height = 400,
      card_header("Ingredients"),
      layout_column_wrap(
        div(
          as_fill_item(),
          class = "overflow-auto",
          tags$blockquote(r$description),
          ui_ingredients(r$ingredients)
        ),
        if (!is.null(r$image_url) && r$image_url != "") {
          div(
            style = css(
              background_image = paste0("url('", r$image_url, "')"),
              background_size = "cover",
              background_position = "center",
              height = "100%",
              width = "100%"
            )
          )
        }
      ),
    ),
    card(
      height = 400,
      style = css(max_height = "max-content"), # don't expand beyond content height
      card_header("Instructions"),
      ui_instructions(r$instructions)
    )
  )
}

ui <- page_sidebar(
  title = "My Recipe Collection",
  sidebar = sidebar(
    width = 300,
    radioButtons(
      "recipes",
      tags$strong("What's for lunch today?"),
      choices = map_chr(recipes, "title")
    )
  ),
  uiOutput("ui_recipe_card", fill = TRUE)
)

server <- function(input, output, session) {
  output$ui_recipe_card <- renderUI({
    req(input$recipes)
    r <- keep(recipes, ~ .x$title == input$recipes)[[1]]
    ui_recipe(r)
  })
}

shinyApp(ui, server)
