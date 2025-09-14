library(ellmer)

age_free_text <- list(
  "I go by Alex. 42 years on this planet and counting.",
  "Pleased to meet you! I'm Jamal, age 27.",
  "They call me Li Wei. Nineteen years young.",
  "Fatima here. Just celebrated my 35th birthday last week.",
  "The name's Robert - 51 years old and proud of it.",
  "Kwame here - just hit the big 5-0 this year."
)

chat <- chat(
  "openai/gpt-5-nano",
  system_prompt = "Extract the name and age."
)

chat$chat(age_free_text[[1]])
chat$chat(age_free_text[[2]])

type_person <- type_object(
  name = type_string(),
  age = type_integer()
)
chat$chat_structured(age_free_text[[1]], type = type_person)


chat <- chat("openai/gpt-5-nano")
chat$chat_structured(age_free_text, type = type_person)
chat


parallel_chat_structured(chat, as.list(age_free_text), type = type_person)

chat <- chat("anthropic/claude-3-5-haiku-20241022")
batch_chat_structured(
  chat,
  age_free_text,
  type = type_person,
  path = "people.json"
)
