# %%
import NWS

posit_conf = {"lat": "33.761627", "lon": "-84.386963"}

# Initiate the NWS API
NWS.InitiateAPI("posit::conf(2025)", "conf@posit.co")

# Get the forecast for the posit::conf location
forecast = NWS.GetCurrentForecast(posit_conf["lat"], posit_conf["lon"])


# %%
# ---- ⚒️ Let's turn this into a tool 🛠️ ----
def get_weather(lat: float, lon: float):
    pass


# %%
# The tool is callable!
weather = get_weather(posit_conf["lat"], posit_conf["lon"])
weather

# %%
# ---- 🧰 Teach an LLM that we have this tool ----
import chatlas

chat = chatlas.ChatOpenAI(model="gpt-4.1-nano")
# register the tool

# %%
# Use the chatbot to answer questions using the tool
chat.chat("What should I wear to posit::conf(2025) in Atlanta?")
