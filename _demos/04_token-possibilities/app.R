library(shiny) # pak::pak("rstudio/shiny")
library(bslib) # pak::pak("rstudio/bslib")
library(dplyr)
library(purrr)

`%||%` <- function(x, y) if (is.null(x)) y else x

chat_with_completion_log_probs <- function(
  input,
  system_prompt = NULL,
  temperature = 0.5
) {
  chat <- ellmer::chat_openai(
    model = "gpt-4.1-nano",
    system_prompt = system_prompt %||%
      "You are a concise and helpful sentence finisher.",
    params = ellmer::params(
      log_probs = TRUE,
      top_logprobs = 5,
      temperature = temperature
    ),
  )

  chat$chat(input, echo = "none")

  chat$last_turn()@json$choices[[1]]$logprobs$content |>
    purrr::map_dfr(
      function(x) {
        res <- purrr::map_dfr(x$top_logprobs, \(x) x[c("token", "logprob")])
        if (!x$token %in% res$token) {
          res <- dplyr::bind_rows(res, x[c("token", "logprob")])
        }
        res$chosen <- res$token == x$token
        res
      },
      .id = "index"
    ) |>
    dplyr::mutate(
      index = as.integer(index),
      prob = exp(logprob),
      confidence = dplyr::case_when(
        logprob < -5 ~ "very-low",
        logprob < -2 ~ "low",
        logprob < -1 ~ "medium",
        logprob < -0.1 ~ "high",
        .default = "very-high"
      )
    )
}

add_noWS_to_tags <- function(x) {
  # Base case: if x is not a list, return it unchanged
  if (!is.list(x)) {
    return(x)
  }

  # Check if the current element is a shiny.tag
  if (inherits(x, "shiny.tag")) {
    # Add .noWS = "outside" attribute if it doesn't already exist
    if (is.null(x$.noWS)) {
      x$.noWS <- "outside"
    }
  }

  # Recursively process all children/elements
  x[] <- lapply(x, add_noWS_to_tags)

  return(x)
}

token_tooltip_component <- function(tokens_data, delay = NULL) {
  id <- paste0("prompt-", rlang::hash(tokens_data))

  token_elements <-
    tokens_data |>
    group_by(index) |>
    group_map(function(alternatives, .group) {
      alternatives <- alternatives |> arrange(desc(logprob))

      chosen_token <- alternatives$token[alternatives$chosen]
      chosen_token <- gsub("\n", "<br>", chosen_token, fixed = TRUE)
      chosen_confidence <- alternatives$confidence[alternatives$chosen]

      if (nrow(alternatives) == 0) {
        return(span(
          class = paste0("token confidence-", tolower(chosen_confidence)),
          chosen_token
        ))
      }

      # Create a table row for each alternative
      table_rows <-
        alternatives |>
        pmap(function(token, logprob, chosen, ...) {
          tags$tr(
            tags$td(
              class = if (chosen) "fw-bold",
              token
            ),
            tags$td(
              scales::percent(exp(logprob), accuracy = 0.001),
              class = "text-end",
              class = if (chosen) "fw-bold"
            )
          )
        })

      # Create the alternatives table container
      alt_table <- tags$table(
        class = "table table-sm token-table",
        `data-bs-theme` = "dark",
        tags$thead(
          tags$tr(
            tags$th("Token"),
            tags$th("Prob", class = "text-end")
          )
        ),
        tags$tbody(table_rows)
      )

      # Tokens are wrapped in spans with a confidence rating class
      token_span <- span(
        class = paste0("token confidence-", tolower(chosen_confidence)),
        HTML(chosen_token)
      )

      # And then tokens get a tooltip that shows the alternatives table
      tooltip(
        token_span,
        alt_table,
        options = list(
          # Click to show the tooltip, also means it stays visible until
          # dismissed with a second click. Useful for comparing between tokens.
          trigger = "click"
        )
      )
    })

  style_tag <- tags$style(HTML(
    "
    .token-tooltip-container {
      font-size: 1.2rem;
      font-family: 'Courier New', monospace;
      line-height: 1.66;
      word-break: break-word;
    }
    .token-table {
      --bs-table-bg: transparent;
    }
    .token {
      padding: 2px;
      border-radius: 6px;
      cursor: pointer;
      white-space: pre;
      border: 1px solid var(--bs-body-bg);
      color: var(--fg, #000);
      background-color: var(--bg, #fff);
      border-bottom: 2px solid var(--border-accent, var(--bs-body-bg));
    }
    .confidence-very-high {
      --bg: #dee8ff;
      --fg: #011b55;
      --border-accent: #5b8efd;
    }
    .confidence-high {
      --bg: #e3dffc;
      --fg: #12074b;
      --border-accent: #725def;
    }
    .confidence-medium {
      --bg: #f8d3e5;
      --fg: #37081f;
      --border-accent: #dd217d;
    }
    .confidence-low {
      --bg: #ffdfcc;
      --fg: #401700;
      --border-accent: #ff5f00;
    }
    .confidence-very-low {
      --bg: #ffefcf;
      --fg: #442d00;
      --border-accent: #ffb00d;
    }
    .bs-popover-auto {
      max-width: 300px;
    }
    .table th, .table td {
      padding: 0.25rem 0.5rem;
    }
  "
  ))

  reveal_sequentially <- tags$script(
    HTML(sprintf(
      "revealSequentially('#%s .token', {%s});",
      id,
      if (is.null(options)) "" else sprintf("delay: %d", delay)
    ))
  )

  tagList(
    div(
      id = id,
      class = "token-tooltip-container",
      !!!add_noWS_to_tags(token_elements),
      style_tag
    ),
    reveal_sequentially
  )
}

ui <- page_navbar(
  title = "Token Possibilities",
  sidebar = sidebar(
    width = "33%",
    style = css(height = "100%"),
    textAreaInput(
      "prompt",
      tagList(icon("pencil"), "Prompt"),
      value = "Write a funny limerick about a cat.",
      rows = 4,
      autoresize = TRUE,
    ),
    input_task_button(
      "submit",
      "Submit",
      icon = icon("paper-plane"),
      class = "btn-primary"
    ),
    accordion(
      open = FALSE,
      style = css(margin_top = "auto"),
      accordion_panel(
        "Settings",
        icon = bsicons::bs_icon("sliders"),
        class = "bg-light",
        textAreaInput(
          "system_prompt",
          tagList(bsicons::bs_icon("robot"), "System prompt"),
          value = "You are a concise and helpful sentence finisher.",
          rows = 4,
          autoresize = TRUE
        ),
        sliderInput(
          "temperature",
          tagList(bsicons::bs_icon("brightness-alt-high-fill"), "Creativity"),
          min = 0,
          max = 1,
          value = 0.5,
          step = 0.1,
          ticks = FALSE
        ),
        radioButtons(
          "speed",
          tagList(bsicons::bs_icon("speedometer2"), "Model speed"),
          inline = TRUE,
          selected = 100,
          choices = c(
            "🐢 Slow" = 750,
            "🚗 Fast" = 100,
            "⚡ Instant" = 20
          ),
        )
      )
    )
  ),
  header = tagList(
    useBusyIndicators(),
  ),
  id = "tab",
  nav_spacer(),
  nav_panel(
    "Response",
    value = "response",
    icon = icon("robot", class = "me-1"),
    uiOutput("completion"),
  ),
  nav_panel(
    "Ideas",
    value = "ideas",
    icon = icon("lightbulb", class = "me-1"),
    shinychat::output_markdown_stream(
      id = "ideas-markdown",
      content = readLines("ideas.md")
    )
  ),
  footer = tags$head(
    tags$script(
      HTML(
        r"(
function revealSequentially(selector, options = {}) {
  const elements = document.querySelectorAll(selector);
  const delay = options.delay || 100;
  const duration = options.duration || 500;

  elements.forEach((el, index) => {
    // Set initial state
    el.style.opacity = '0';
    el.style.transition = `opacity ${duration}ms`;

    // Trigger animation after staggered delay
    setTimeout(() => {
      el.style.opacity = '1';
      el.style.transform = 'translateY(0)';
    }, index * delay);
  });
}
      )"
      )
    )
  )
)

server <- function(input, output, session) {
  completion <- eventReactive(input$submit, {
    updateTabsetPanel(session, "tab", selected = "response")
    chat_with_completion_log_probs(
      input$prompt,
      system_prompt = input$system_prompt,
      temperature = input$temperature
    )
  })

  output$completion <- renderUI({
    token_tooltip_component(completion(), delay = as.integer(input$speed))
  })

  outputOptions(output, "completion", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
