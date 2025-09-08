library(ellmer)

words <- readLines(
  here::here("_exercises/06-word-games/words.txt")
)

chat <- chat_openai(
  system_prompt = interpolate(
    r"--(
We are playing a word guessing game.
Here's the secret words: {{ sample(words, 1) }}.
Give the user an initial clue and then only answer their questions with yes or no.
When they win, use lots of emojis.
  )--"
  )
)

# Start the chat and say "Let's play"
live_console(chat)
