library(ellmer)

models_openai() # openai/gpt-5-nano
models_anthropic() # anthropic/claude-3-5-haiku-20241022
models_ollama() # ollama/gemma3:8b

chat <- chat_ollama(model = "gemma3:8b")
chat$chat(
  "Write a recipe for an easy weeknight dinner my kids would like"
)
