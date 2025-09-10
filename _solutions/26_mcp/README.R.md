## Use an MCP server in Positron

(If you're not using Positron, find a nearby partner who is to work with.)

## What MCP servers are out there in the world?

Take a minute to browse the list of [Awesome MCP Servers](https://github.com/punkpeye/awesome-mcp-servers).
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

df = pl.read_csv(here("data/penguins.csv"))

island_summary = (
    df.group_by("island")
    .agg(
        sample_size=pl.len(),
        prop_female=(pl.col("sex").eq("female").sum() / pl.col("sex").len()),
        mean_bill_depth_mm=pl.col("bill_depth_mm").mean(),
        std_bill_depth_mm=pl.col("bill_depth_mm").std(),
        mean_flipper_length_mm=pl.col("flipper_length_mm").mean(),
        std_flipper_length_mm=pl.col("flipper_length_mm").std(),
        mean_body_mass_g=pl.col("body_mass_g").mean(),
        std_body_mass_g=pl.col("body_mass_g").std(),
    )
    .sort("island")
)

island_summary
```

---

This example is based on [Tidy Data Manipulation: dplyr vs polars – Tidy Intelligence](https://blog.tidy-intelligence.com/posts/dplyr-vs-polars/).
