# Programming with LLMs

## Setup thoughts

- Positron Assistant: https://positron.posit.co/assistant
  - Requires turning on settings

- Databot (recommended extension), requires setting up PA

## Morning 1: Anatomy of a conversation (90m)

> An introduction to basic LLM concepts and how to use `ellmer` and `chatlas` to interact with LLMs from R and Python. No prior experience with LLMs is assumed, but some programming experience is helpful.

- (10m) Welcome, introductions, workshop expectations
  - Activity: introduce yourself to your neighbors

- (10m) Set-up and verify API access
  - Activity: simple script to verify API access (write an "I'm at posit::conf(2025) social media post")

- (10m) Think empirically, be pragmatic
  - Getting into the right mindset for working with LLMs
  - This section gives us some extra time to troubleshoot any setup issues

- (20m) Anatomy of a conversation
  - To get a get a response, you send a message via HTTP
  - Message roles: system, user, assistant
  - Activity: Word guessing game
    - System prompt: _You are playing a word guessing game. At each turn, guess the word and tell us what it is._
    - We give a few questions to ask
    - Also include a modifier in the first message, e.g. "In ____, ..." picking from "British English", "pirate", "Spanish", etc.
    - The modifier in the first message steers subsequent answers
  - The conversation is **stateless**
    - Use **clearbot** to walk through an example, showing the requests and responses
    - First: _Using British spellings, guess the word for the person living next door._
    - Second: _What helps a car move smoothly down the road?_
    - Clear the chat and try second question again.

- (20m) How do LLMs work?
  - _How to Talk to Robots_ slides
  - Tokens as the fundamental unit
  - Example: `_demos/04_token-possibilities`

- (20m) Shinychat basics
  - Activity: `live_console()` and `live_browser()` (or `chat.console()` and `chat.app()`)
  - Making your own shinychat app with `chat.ui()` and `chat.append()`. R users can use the chat module with `chat_mod_server()`.
  - Activity: Reverse the word-guessing game with the word to guess in the system prompt. User has to guess, LLM gives hints.

## Morning 2: Programming with LLMs (90m)

> A deeper dive into the things you can do with LLMs when you're programming with them that are harder to do in a chat UI.

- (15m) Choosing a model
  - Overview of major providers: OpenAI, Anthropic, Google, ollama
  - Tradeoffs: capability, context length, speed, cost, intelligence
  - Activity: same question, change one string to switch models, e.g. `chat("openai")`, `chat("anthropic")`.

- (15m) Multi-modal input (vision, PDF)
  - Activity: images of food and ask for recipes
  - Activity: take a PDF of a recipe, turn it into markdown

- (15m) Structured output
  - Explain `ellmer::type_*()` or [pydantic model in chatlas](https://posit-dev.github.io/chatlas/get-started/structured-data.html)
  - Activity: Extract rich data from the recipe PDF
  - Note [use_attribute_docstrings](https://docs.pydantic.dev/latest/api/config/#pydantic.config.ConfigDict.use_attribute_docstrings)

- (10m) Parallel/batch calls
  - Support will hopefully land in chatlas before conf
  - Activity: Extract recipe data in parallel or batch

- (35m) Prompting engineering and hallucinations
  - Activity: images of mpg vs weight and ask for interpretation
  - Activity (part 1): same question, but we've replaced the image with random noise
  - Activity (part 2): work with partner to try to get the model to give you a decent interpretation of the random noise image
  - Prompt engineering best practices, in particular the system prompt
  - Activity: create [the prompt for the quiz game show](https://github.com/jcheng5/llm-quickstart/blob/main/02-tools-prompt.md)

## Afternoon 1: Augmented Generation (90m)

> How to add knowledge to LLMs and make them more useful for specific tasks. We implement a simple RAG system, which also naturally introduces the concept of tool calling.

- (10m) Manual RAG
  - Activity: Data science coding assistant
    - Given a data science task using `polars` or `dplyr`, ask an LLM to generate or explain code, first without any context.
    - Then, give it the relevant section of the `polars` or `dplyr` documentation and see how much better the response is.

- (30m) RAG
  - High-level overview of how RAG works
  - Activity: Build a dynamic RAG system
    - We'll have the complete, raw `dplyr` or `polars` documentation.
    - Preprocess and compute embeddings for each chunk using `ragnar` or `llama-index`
      - https://posit-dev.github.io/chatlas/misc/RAG.html#dynamic-retrieval
      - https://ragnar.tidyverse.org/articles/ragnar.html#setting-up-rag
    - Add a tool that searches the embeddings and returns the top few chunks
      - chatlas: this means writing a function
      - ellmer: Use `ragnar`

- (20m) Tool calling
  - Explain how tool calling pattern, mostly following <https://pkg.garrickadenbuie.com/genAI-2025-llms-meet-shiny>
  - Activity: quiz show
    - We provide an R/Python function that plays a sound
      - R: `beepr`, Python: [playsound](https://pypi.org/project/playsound3/)
    - They document the function and register it as a tool in the Quiz Show app

- (30m) Tool calling UI
  - Primarily a series of activities that progressively enhance the quiz show app
  - Activity: Add tool annotations to give the tool an icon and title
  - Activity: Use `ContentToolResult` to return custom title and icon
  - Activity: Track answers and score in the app (add/update value boxes)
  - (Considering) Activity: Add tool to check score and finalize a round with a display of the final score and questions asked.

## Afternoon 2: Beyond Tools (90m)

> A look at more advanced topics, including MCP and agents.

- (10m) querychat
  - Activity: Add querychat into an existing shiny app

- (10m) MCP
  - Overview of MCP and how it works
  - MCP in Positron: https://github.com/posit-dev/positron/issues/8377
    - MCP in VS Code: https://code.visualstudio.com/docs/copilot/customization/mcp-servers

  - Activity: Connect an MCP server to ellmer/chatlas (options from https://github.com/punkpeye/awesome-mcp-servers below)
    - ArXiV: https://github.com/andybrandt/mcp-simple-arxiv
    - webpage screenshot: https://github.com/ananddtyagi/webpage-screenshot-mcp
    - stocky: https://github.com/joelio/stocky
    - fetcher: https://github.com/jae-jae/fetcher-mcp
    - git-ingest: https://github.com/adhikasp/mcp-git-ingest
    - github: https://arc.net/l/quote/bvfqahnx
    - context7: https://github.com/upstash/context7

- (30m) Agents
  - Hadley/Willison definition: Agents are LLMs with a read tool and a write tool
  - The "you know it when you see it" definition: autonomous LLMs, long context, minimal intervention
  - Demobot demo

- (30m) The Future of AI
  - Where do we go from here? Let's talk fears and hopes.

- (5m) Wrap-up
  - Feedback survey
