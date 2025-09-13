library(ellmer)

# Your job: work with a chatbot to roast Hadley Wickham.
chat <- chat_openai()

# Converse with the chatbot in your console.
live_console(chat)

# After a bit, exit the chat and try chatting in a Shiny app.
live_browser(chat)
