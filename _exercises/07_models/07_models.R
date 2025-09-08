library(ellmer)

# List models using the `models_*()` functions.
# Hint: try using the Positron data viewer by calling `View()` on the results.
models_openai() # openai/gpt-5-nano
models_anthropic() # anthropic/claude-3-5-haiku-20241022
models_ollama() # ollama/gemma3:8b

# Try sending the same prompt to different models to compare the responses.
chat("openai/gpt-5")$chat(prompt)
chat("anthropic/claude-3-7-sonnet-20250219")$chat(prompt)

# If you have local models installed, you can use them too.
chat("ollama/gemma3:4b")$chat(prompt)
