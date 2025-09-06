library(ellmer)

models_openai()
models_anthropic()
models_ollama()

chat <- chat_ollama(model = "phi4-mini")
chat$chat(
  "Write a recipe for an easy weeknight dinner my kids would like"
)
