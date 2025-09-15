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
Ask PA to "Convert this polars code to dplyr code".

You may also want to include `#content7` to your prompt to tell PA to use the MCP server.

```python
import polars as pl
from pyhere import here

listings = pl.read_csv(here("data/airbnb-asheville.csv"))

hot_room_types = (
    listings.group_by(["neighborhood", "room_type"])
    .agg(
        [
            pl.len().alias("total_listings"),
            pl.col("price").mean().round(2).alias("avg_price"),
            pl.col("score_rating").mean().round(2).alias("avg_rating"),
            # occupied days = 365 - availability_365
            (365 - pl.col("availability_365")).sum().alias("total_occupied_days"),
            (365 - pl.col("availability_365").mean()).alias("avg_occupied_days"),
            pl.col("n_reviews").sum().alias("total_reviews"),
        ]
    )
    .with_columns(
        (pl.col("total_reviews") / pl.col("total_listings")).alias(
            "reviews_per_listing"
        )
    )
    .group_by("neighborhood")
    .map_groups(lambda df: df.sort("reviews_per_listing", descending=True).head(1))
    .sort("avg_occupied_days", descending=True)
    .select(
        "neighborhood",
        "room_type",
        "total_listings",
        "avg_price",
        "total_occupied_days",
        "avg_occupied_days",
        "total_reviews",
        "reviews_per_listing",
    )
)

print(hot_room_types)
```
