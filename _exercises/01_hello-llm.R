library(ellmer)

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
