# In this workshop, we'll be using the ellmer package to interact with Large
# Language Models (LLMs) like OpenAI's GPT and Anthropic's Claude.
# https://ellmer.tidyverse.org/
library(ellmer)

# I've configured this project to automatically load the API keys from `.env` in
# the project root. If you need to load them manually, you can use:
#
# dotenv::load_dotenv(here::here(".env"))

# ---- OpenAI ----
chat_gpt <- chat_openai()
chat_gpt$chat(
  "I'm at posit::conf(2025) to learn about programming with LLMs and ellmer!",
  "Write a short social media post for me."
)

# ---- Anthropic ----
chat_claude <- chat_anthropic()
chat_claude$chat(
  "I'm at posit::conf(2025) to learn about programming with LLMs and ellmer!",
  "Write a short poem to celebrate."
)
