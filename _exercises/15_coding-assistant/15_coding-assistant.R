# Task ------------------------------------------------------------------------
library(ellmer)

# **Step 1:** Run the code below as-is to try the task without any extra
# context. How does the model do? Can you run the function? Does it give you the
# weather? Does it know enough about the {weathR} package to complete the task?
#
# **Step 2:** Now, let's add some context. Head over to GitHub repo for {weathR}
# (link in `docs.R.md`). Copy the project description from the `README.md` and
# paste it into the `docs.py.md` file.
#
# **Step 3:** Uncomment the extra lines to include these docs in the prompt and
# try again.

chat <- chat("anthropic/claude-3-5-sonnet-20241022", echo = "output")

chat$chat(
  ## Extra context from package docs
  # brio::read_file(here::here("_exercises/15_coding-assistant/docs.R.md")),
  ## Task prompt
  paste(
    "Write a simple function that takes latitude and longitude as inputs",
    "and returns the weather forecast for that location using the {weathR}",
    "package. Keep the function concise and simple and don't include error",
    "handling or data re-formatting. Include documentation in roxygen2 format,",
    "including examples for NYC and Atlanta, GA."
  )
)
