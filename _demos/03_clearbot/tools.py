import functools
import json
import os
import traceback
from typing import Callable, ParamSpec, TypeVar, Union

import requests
from duckduckgo_search import DDGS

P = ParamSpec("P")
R = TypeVar("R")


def safe_errors(func: Callable[P, R]) -> Callable[P, Union[R, str]]:
    @functools.wraps(func)
    def wrapped(*args: P.args, **kwargs: P.kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            return f"An error has occurred:\n{traceback.format_exception(e)}"

    return wrapped


@safe_errors
def get_current_dir() -> str:
    """Gets the current working directory."""

    return os.getcwd()


@safe_errors
def set_current_dir(path: str) -> None:
    """Sets the current directory to the given (relative or absolute) path"""

    os.chdir(path)


@safe_errors
def list_dir(path: str = ".") -> list[str]:
    """Returns a list of files and directories in the given directory."""

    return os.listdir(path)


@safe_errors
def read_text_file(path: str, encoding: str = "UTF-8") -> str:
    """Reads the file at the given path as a string."""

    with open(path, encoding=encoding) as f:
        return f.read()


@safe_errors
def get_weather_forecast(lat: float, lon: float):
    """Get weather forecast using NWS API directly and return as markdown"""
    # Step 1: Get grid points from NWS
    points_url = f"https://api.weather.gov/points/{lat},{lon}"
    response = requests.get(points_url)
    response.raise_for_status()

    points_data = response.json()
    forecast_url = points_data["properties"]["forecast"]

    # Step 2: Get the actual forecast
    forecast_response = requests.get(forecast_url)
    forecast_response.raise_for_status()

    forecast_data = forecast_response.json()

    # Return only the first two periods (e.g. today and tonight)
    periods = forecast_data["properties"]["periods"][:2]

    markdown_output = ""
    for period in periods:
        if markdown_output:
            markdown_output += "\n\n"
        markdown_output += f"## {period['name']}\n\n"
        markdown_output += (
            f"Temperature: {period['temperature']}°{period['temperatureUnit']}\n"
        )
        markdown_output += f"Wind: {period['windSpeed']} {period['windDirection']}\n"
        markdown_output += f"Short Forecast: {period['shortForecast']}\n"
        markdown_output += f"Detailed Forecast: {period['detailedForecast']}"

    return markdown_output


@safe_errors
def google_search(query: str, start: int = 1):
    """Searches the web using the Google search engine."""

    # Make a request to https://customsearch.googleapis.com/customsearch/v1?cx={os.environ.GOOGLE_SEARCH_ENGINE_ID}&q=&key={os.environ.GOOGLE_API_KEY}
    response = requests.get(
        "https://customsearch.googleapis.com/customsearch/v1",
        params={
            "cx": os.environ["GOOGLE_SEARCH_ENGINE_ID"],
            "q": query,
            "key": os.environ["GOOGLE_API_KEY"],
            "num": 10,
            "start": start,
        },
    )
    response.raise_for_status()
    results = response.json()
    return json.dumps(
        [
            {
                "title": item["title"],
                "link": item["link"],
                "snippet": item["snippet"],
            }
            for item in results["items"]
        ],
        indent=2,
    )


@safe_errors
def duckduckgo_search(query: str, max_results: int = 20):
    """Searches the web using the DuckDuckGo search engine."""

    # In theory, max_results shouldn't need to be coerced to an int. In
    # practice, Llama 3.2 passes the wrong type sometimes.
    return DDGS().text(query, max_results=int(max_results))


@safe_errors
def http_get(url: str) -> str:
    """Retrieves the contents of a URL using an HTTP GET request. Turns HTML into plaintext."""

    # Lie about the user agent to avoid 403 Forbidden errors.
    response = requests.get(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36",
            "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
            "accept-language": "en-US,en;q=0.9",
            "cache-control": "no-cache",
            "pragma": "no-cache",
            "priority": "u=0, i",
            "sec-ch-ua": '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
            "sec-ch-ua-mobile": "?1",
            "sec-ch-ua-platform": '"Android"',
            "sec-fetch-dest": "document",
            "sec-fetch-mode": "navigate",
            "sec-fetch-site": "none",
            "sec-fetch-user": "?1",
            "upgrade-insecure-requests": "1",
        },
    )
    response.raise_for_status()
    # If HTML, convert to text using Pandoc. If plaintext, leave it alone.
    if "text/html" in response.headers["Content-Type"]:
        import pandoc

        doc = pandoc.read(response.text, format="html")
        return pandoc.write(doc, format="plain")
    else:
        # Return plaintext
        return response.text


search_tools = [http_get]
if os.environ.get("GOOGLE_API_KEY") and os.environ.get("GOOGLE_SEARCH_ENGINE_ID"):
    search_tools.append(google_search)
else:
    search_tools.append(duckduckgo_search)

all_tools: dict[str, list[Callable]] = {
    "weather": [get_weather_forecast],
    "filesystem": [
        get_current_dir,
        set_current_dir,
        list_dir,
        read_text_file,
    ],
    "websearch": search_tools,
}
