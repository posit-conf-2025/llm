#%%
import chatlas
from dotenv import load_dotenv

load_dotenv()

#%%
chatlas.ChatOpenAI().list_models()
[m["id"] for m in chatlas.ChatOpenAI().list_models()]

chatlas.ChatAnthropic().list_models()
chatlas.ChatOllama("gemma3").list_models()

#%%
chat = chatlas.ChatOllama("phi4-mini")
chat.chat(
  "Write a recipe for an easy weeknight dinner my kids would like"
)