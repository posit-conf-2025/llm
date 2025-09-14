library(ellmer)

# Step 1: List available models for OpenAI and Anthropic
# List models using the `models_*()` functions.
# Hint: try using the Positron data viewer by calling `View()` on the results.
models_____
models_____

prompt <- "Write a  recipe for an easy weeknight dinner my kids would like."

# Step 2: Compare responses from different models
# Try sending the same prompt to different models to compare the responses.
chat("openai/____")$chat(prompt)
chat("anthropic/____")$chat(prompt)

# Bonus: Local models?
# If you have local models installed, you can use them too.
models_ollama()
chat("ollama/____")$chat(prompt)

# Bonus: Repeat your OpenAI and Anthropic requests using direct provider
# functions.
chat_____(____)$chat(prompt)
