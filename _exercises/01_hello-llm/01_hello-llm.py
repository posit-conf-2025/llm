import chatlas
import dotenv

dotenv.load_dotenv()

# ---- OpenAI ----
chat_gpt = chatlas.ChatOpenAI()
chat_gpt.chat(
    "I'm at posit::conf(2025) to learn about programming with LLMs and ellmer! "
    "Write a short social media post for me."
)


# ---- Anthropic ----
chat_claude = chatlas.ChatAnthropic()
chat_claude.chat(
    "I'm at posit::conf(2025) to learn about programming with LLMs and ellmer!",
    "Write a short poem to celebrate.",
)
