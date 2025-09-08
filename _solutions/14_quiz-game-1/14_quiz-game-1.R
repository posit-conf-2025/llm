library(ellmer)

chat <- chat(
  "anthropic/claude-3-7-sonnet-20250219",
  system_prompt = interpolate_file(
    here::here("_solutions/14_quiz-game-1/prompt.md")
  )
)

. <- chat$chat("Begin", echo = FALSE) # get LLM to give us the greeting
chat$set_turns(chat$get_turns()[-1]) # remove first "Begin" message
live_browser(chat, quiet = TRUE)
