# %%
import NWS

posit_conf = {"lat": "33.761627", "lon": "-84.386963"}

# Initiate the NWS API (replace with your app name and email)
NWS.InitiateAPI("posit::conf(2025)", "conf@posit.co")

# Get the forecast for the posit::conf location
forecast = NWS.GetCurrentForecast(posit_conf["lat"], posit_conf["lon"])


# %%
# ---- ⚒️ Let's turn this into a tool 🛠️ ----
def get_weather(lat: float, lon: float):
    """
    Get forecast data for a specific latitude and longitude.

    Parameters
    ----------
    lat : str
        Latitude of the location.
    lon : str
        Longitude of the location.
    """
    return NWS.GetCurrentForecast(lat, lon)


# %%
# The tool is callable!
weather = get_weather(posit_conf["lat"], posit_conf["lon"])
weather

# %%
# ---- 🧰 Teach an LLM that we have this tool ----
import chatlas

chat = chatlas.ChatAuto("openai/gpt-4.1-nano")
chat.register_tool(get_weather)

# %%
# Use the chatbot to answer questions using the tool
chat.chat("What should I wear for a walk during posit::conf() in Atlanta?")
