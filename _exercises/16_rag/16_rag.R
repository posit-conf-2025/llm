#+ setup
library(ragnar)

# Step 1: Read, chunk and create embeddings for "R for Data Science" ----------

#' This example is based on https://ragnar.tidyverse.org/#usage.
#'
#' The first step is to crawl the R for Data Science website to find all the
#' pages we'll need to read in.
#'
#' Then, we create a new ragnar document store that will use OpenAI's
#' `text-embedding-3-small` model to create embeddings for each chunk of text.
#'
#' Finally, we read each page as markdown, use `markdown_chunk()` to split that
#' markdown into reasonably-sized chunks, finally inserting each chunk into the
#' vector store. That insertion step automatically sends the chunk text to
#' OpenAI to create the embedding, and ragnar stores the embedding alongside the
#' original text of the chunk.

#+ create-store

base_url <- "https://r4ds.hadley.nz"
pages <- ragnar_find_links(base_url, children_only = TRUE)

store_location <- here::here("_exercises/16_rag/r4ds.ragnar.duckdb")

store <- ragnar_store_create(
  store_location,
  title = "R for Data Science",
  # Need to start over? Set `overwrite = TRUE`.
  # overwrite = TRUE,
  embed = \(x) embed_openai(x, model = "text-embedding-3-small")
)

cli::cli_progress_bar(total = length(pages))
for (page in pages) {
  cli::cli_progress_update(status = page)

  chunks <- page |>
    read_as_markdown() |>
    # The next step breaks the markdown into chunks. This is where you have the
    # most control over what content is grouped together for embedding and later
    # retrieval. Feel free to experiment with settings in `?markdown_chunk()`.
    markdown_chunk()

  ragnar_store_insert(store, chunks)
}
cli::cli_progress_done()

ragnar_store_build_index(store)

# Step 2: Inspect your document store -----------------------------------------

#' Now that we have the vector store, what chunks are surfaced when we ask a
#' question? To do that, we'll use the ragnar store inspector app and an
#' example question.
#'
# Here's a question someone might ask an LLM. Copy the task markdown to use in
# the ragnar store inspector app.

#+ inspect-store
task <- r"--(
Could someone help me filter one data frame by matching values in another?

I’ve got two data frames with a common column `code.` I want to keep rows in `data1` where `code` exists in `data2$code`. I tried using `filter()` but got no rows back.

Here’s a minimal example:

```r
library(dplyr)

data1 <- data.frame(
    closed_price = c(49900L, 46900L, 46500L),
    opened_price = c(51000L, 49500L, 47500L),
    adjust_closed_price = c(12951L, 12173L, 12069L),
    stock = as.factor(c("AAA", "AAA", "AAC")),
    date3 = as.factor(c("2010-07-15", "2011-07-19", "2011-07-23")),
    code = as.factor(c("AAA2010", "AAA2011", "AAC2011"))
)

data2 <- data.frame(
    code = as.factor(c("AAA2010", "AAC2011")),
    ticker = as.factor(c("AAA", "AAM"))
)
```

What I tried:

```r
price_code <- data1 %>% filter(code %in% data2)
```

This returns zero rows. What’s the simplest way to do this?
)--"

ragnar_store_inspect(store)


# Step 3: Use document store in a chatbot --------------------------------------

#' Finally, ragnar provides a special tool that attaches to an ellmer chat
#' client and lets the model retrieve relevant chunks from the vector store on
#' demand. Run the code below to launch a chatbot backed by all the knowledge in
#' the R for Data Science book. Paste the task markdown from above into the chat
#' and see how the chatbot uses the retrieved chunks to improve its answer, or
#' ask it your own questions about R for Data Science.

#+ chatbot

library(ellmer)

chat <- chat(
  name = "openai/gpt-4.1-nano",
  system_prompt = r"--(
You are an expert R programmer and mentor. You are concise.

Before responding, retrieve relevant material from the knowledge store. Quote or
paraphrase passages, clearly marking your own words versus the source. Provide a
working link for every source you cite.
  )--"
)

# Attach the retrieval tool to the chat client. You can choose how many chunks
# or documents are retrieved each time the model uses the tool.
ragnar_register_tool_retrieve(chat, store, top_k = 10)

live_browser(chat)
