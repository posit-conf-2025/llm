# Clearbot

Clearbot is a chatbot UI designed to illustrate a few features of LLM APIs. It is built using [Shiny](https://) (Python) and Chatlas.

It has three main features:

1. Allows you to set the system prompt, temperature, and other parameters.
2. Has toggle-able tools for filesystem access and web search.
3. Lets you inspect the underlying JSON request/response data.

## Requirements

You can either set these environment variables manually, or include a [`.env` file](https://saurabh-kumar.com/python-dotenv/) in the root directory of your project.

At least one of the following environment variables is **required**:

- `OPENAI_API_KEY` - Used to access OpenAI LLM models.
- `ANTHROPIC_API_KEY` - Used to access Anthropic LLM models.

### Web search

Web search is an optional feature that allows the chatbot to use Google to perform web searches. This involves creating a [Google Programmable Search Engine](https://programmablesearchengine.google.com/) and [getting an API Key](https://developers.google.com/custom-search/v1/introduction).

- `GOOGLE_SEARCH_ENGINE_ID` - The ID of your Programmable Search Engine instance. Roughly 18 hexadecimal characters.
- `GOOGLE_API_KEY` - Roughly 39 alphanumeric characters.

## Usage

Using uv:

```python
uv run shiny run app.py
```

Alternatively, use `uv sync` to install the app's dependencies in a virtual environment, and then run the app with `shiny run app.py` (or using VS Code or Positron with the Shiny VS Code extension).

## License

This project is licensed under the MIT License - see the LICENSE file for details.
