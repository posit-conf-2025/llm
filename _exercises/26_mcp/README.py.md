## Use an MCP server in Positron

(If you're not using Positron, find a nearby partner who is to work with.)

## What MCP servers are out there in the world?

Take a minute to browse the list of [MCP Servers](https://github.com/modelcontextprotocol/servers).
Are there any that look interesting to you?

## Setup context7

We're going to set up and use the [context7](https://context7.com/) MCP server, which provides documentation search for popular open-source packages in many languages.
And it's free to use!

1. In Positron, open the command palette and run **MCP: Add Server...**.
2. Choose to add an **HTTP** server .
3. For the URL, enter `https://mcp.context7.com/mcp`.
4. Enter `context7` for the server ID.
5. Decide if you want to add this server to the **Workspace** (just for this workshop), or as **Global** server (available in all your Positron projects).

Now you're ready to use the server in Positron Assistant!

## Task

Use Positron Assistant to help you convert the following polars code to R code that uses dplyr.

Highlight the code block below and then open Positron Assistant.
Ask PA to "Convert this dplyr code to polars".

You may also want to include `#content7` to your prompt to tell PA to use the MCP server.

```r
library(readr)
library(dplyr)

listings <- read_csv(here::here("data/airbnb-asheville.csv"))

hot_room_types <-
  listings |>
  group_by(neighborhood, room_type) |>
  summarize(
    total_listings = n(),
    avg_price = round(mean(price, na.rm = TRUE), 2),
    avg_score = round(mean(score_rating, na.rm = TRUE), 2),
    total_occupied_days = sum(365 - availability_365, na.rm = TRUE),
    avg_occupied_days = (365 - mean(availability_365, na.rm = TRUE)),
    total_reviews = sum(n_reviews, na.rm = TRUE),
    .groups = "drop_last"
  ) |>
  slice_max(total_reviews / total_listings, n = 1) |>
  arrange(desc(avg_occupied_days))

hot_room_types
```

Hint: You might also need to mention that `pyhere` is a drop-in substitute for `here` in R.
