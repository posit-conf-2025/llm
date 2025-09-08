import json
import os
from pathlib import Path
from typing import Iterable, TypeAlias

import chatlas
import openai
from dotenv import load_dotenv
from offcanvas import offcanvas_ui
from pydantic import BaseModel
from shiny import App, Inputs, Outputs, Session, bookmark, reactive, render, req, ui
from starlette.requests import Request
from tools import all_tools

MyTurn: TypeAlias = chatlas.Turn[openai.types.chat.ChatCompletion]

load_dotenv()

model_options = {}

if "OPENAI_API_KEY" in os.environ:
    model_options["OpenAI"] = {
        "gpt-5": "GPT-5 (latest, slowest, smartest)",
        "gpt-5-mini": "GPT-5 mini",
        "gpt-5-nano": "GPT-5 nano (latest, fastest, cheapest)",
        "gpt-4.1": "GPT-4.1 (slowest, smartest)",
        "gpt-4.1-mini": "GPT-4.1 mini",
        "gpt-4.1-nano": "GPT-4.1 nano (fastest, cheapest)",
    }
if "ANTHROPIC_API_KEY" in os.environ:
    model_options["Anthropic"] = {
        "claude-3-7-sonnet-latest": "Claude 3.7 Sonnet",
        "claude-3-5-sonnet-latest": "Claude 3.5 Sonnet",
        "claude-3-5-haiku-latest": "Claude 3.5 Haiku",
    }

if len(model_options) == 0:
    raise ValueError(
        "No API keys found. Please set OPENAI_API_KEY and/or ANTHROPIC_API_KEY in your environment."
    )


def app_ui(request: Request):
    return ui.page_sidebar(
        ui.sidebar(
            ui.input_select(
                "model",
                "Model",
                model_options,
                selected="gpt-4.1-nano",
            ),
            ui.input_text_area("system_prompt", "System prompt", rows=6),
            ui.help_text("Instructs the LLM how to behave"),
            ui.input_slider(
                "temperature", "Temperature", min=0, max=2, value=0.7, step=0.05
            ),
            ui.help_text(
                "Lower for coherence, higher for randomness. (Ignored for Claude and GPT-5 models.)"
            ),
            ui.input_checkbox_group(
                "tools",
                "Tools",
                {
                    "weather": "Weather",
                    "filesystem": "Filesystem access",
                    "websearch": "Web search",
                },
            ),
            width=325,
            title="Settings",
            open="closed",
        ),
        ui.tags.script(src="new-chat-button.js"),
        offcanvas_ui(
            "trace",
            "Trace Inspector",
            ui.TagList(
                ui.input_select("trace_num", "Select a trace", []),
                ui.output_ui("trace_display"),
            ),
            style="--bs-offcanvas-width: min(600px, 100vw);",
        ),
        ui.chat_ui("chat"),
        ui.head_content(
            ui.tags.script(src="json-viewer.js"),
            ui.tags.script(src="main.js"),
            ui.tags.style(
                """
                .help-block {
                    margin-top: -1em;
                }
                """
            ),
        ),
        title="Clearbot",
        fillable=True,
    )


class RequestParams(BaseModel):
    """A snapshot of the parameter values at the moment of a request"""

    model: str
    user_prompt: str
    system_prompt: str
    temperature: float
    tools: list[str]


class SessionState(BaseModel):
    turns: list[MyTurn]
    snapshots: list[tuple[RequestParams, list[MyTurn]]]


def server(input: Inputs, output: Outputs, session: Session):
    turns: reactive.Value[list[MyTurn]] = reactive.Value([])
    snapshots: reactive.Value[list[tuple[RequestParams, list[MyTurn]]]] = (
        reactive.Value([])
    )

    chat = ui.Chat("chat")

    def current_params(user_prompt: str) -> RequestParams:
        return RequestParams(
            model=input.model(),
            user_prompt=user_prompt,
            system_prompt=input.system_prompt(),
            temperature=input.temperature(),
            tools=input.tools(),
        )

    @chat.on_user_submit
    async def chat_on_user_submit(user_prompt: str):
        these_turns = turns()
        params: RequestParams = current_params(user_prompt)

        # chat_client = chatlas.ChatOllama(
        #     model="llama3.2",
        #     system_prompt=params.system_prompt,
        #     turns=these_turns,
        # )
        if params.model.startswith("claude"):
            chat_client = chatlas.ChatOpenAI(
                base_url="https://api.anthropic.com/v1/",
                api_key=os.environ["ANTHROPIC_API_KEY"],
                model=params.model,
                system_prompt=params.system_prompt,
            )
        elif params.model.startswith("gpt"):
            chat_client = chatlas.ChatOpenAI(
                model=params.model,
                system_prompt=params.system_prompt,
            )
        else:
            raise ValueError(f"Unknown model: {params.model}")

        chat_client.set_turns(these_turns)

        for toolset in input.tools():
            for tool in all_tools[toolset]:
                chat_client.register_tool(tool)

        temperature = params.temperature
        if params.model.startswith("gpt-5"):
            temperature = 1

        resp = await chat_client.stream_async(
            params.user_prompt, kwargs=dict(temperature=temperature)
        )

        for tool in params.tools:
            # TODO: Implement tools
            pass

        async def gen():
            async for chunk in resp:
                yield chunk
            with reactive.isolate():
                yield button_for_index(len(snapshots.get()))

        task = await chat.append_message_stream(gen())

        @reactive.Effect
        async def resp_on_complete():
            if task.status() == "success":
                resp_on_complete.destroy()
                turns.set(chat_client.get_turns())
                turns_snapshot = chat_client.get_turns(include_system_prompt=True)
                snapshots.set(snapshots.get() + [(params, turns_snapshot)])
                with reactive.isolate():
                    ui.update_select(
                        "trace_num", choices=list(range(len(snapshots.get())))
                    )
                await session.bookmark()
            if task.status() in ["error", "cancelled"]:
                resp_on_complete.destroy()

    @session.bookmark.on_bookmarked
    async def session_on_bookmarked(url: str):
        print("session_on_bookmarked")
        await session.bookmark.update_query_string(mode="replace")

    @session.bookmark.on_bookmark
    def session_on_bookmark(state: bookmark.BookmarkState):
        ss = SessionState(turns=turns(), snapshots=snapshots())
        print(ss.model_dump_json())
        state.values["session_state"] = ss.model_dump(mode="json")

    @session.bookmark.on_restore
    async def session_on_restore(state: bookmark.BookmarkState):
        if "session_state" in state.values:
            ss = SessionState.model_validate(state.values["session_state"])
            last_turns = ss.snapshots[-1][1]
            turns.set(last_turns)
            snapshots.set(ss.snapshots)
            ui.update_select("trace_num", choices=list(range(len(snapshots.get()))))

            i = 0
            for turn in last_turns:
                if turn.role == "assistant":
                    suffix = button_for_index(i)
                    i += 1
                else:
                    suffix = ""
                await chat.append_message(
                    {
                        "role": turn.role,
                        "content": "\n".join([str(x) for x in turn.contents]) + suffix,
                    }
                )

    @reactive.effect
    @reactive.event(input.clear)
    async def clear_messages():
        print("Clearing messages")
        await chat.clear_messages()
        turns.set([])
        snapshots.set([])

    def button_for_index(i: int) -> str:
        return f"""\n\n<a class="text-decoration-none" href="#" data-snapshot-index="{i}" title="Inspect this request/response">{{…}}</a>"""

    @render.ui
    def trace_display():
        req(len(snapshots()) > 0)
        (params, turns) = snapshots()[
            int(input.trace_num()) or 0
            if "trace_num" in input and input.trace_num() is not None
            else 0
        ]

        dump = reconstruct_request_traces(params, turns[0:-1])
        print(json.dumps(dump, indent=2))

        resp = reconstruct_response_traces(turns[-1])

        return ui.TagList(
            ui.h4("Request"),
            # ui.Tag("json-viewer", data=params.model_dump_json(indent=2)),
            ui.Tag("json-viewer", data=json.dumps(dump)),
            ui.h4("Response", class_="mt-3"),
            ui.Tag("json-viewer", data=json.dumps(resp)),
        )


def reconstruct_request_traces(
    params: RequestParams, turns: Iterable[MyTurn]
) -> list[object]:
    tools_schema = reconstruct_tools_schema(params.tools)

    msgs = [t.model_dump_json() for t in turns]
    msgs = [json.loads(t) for t in msgs]
    msgs = [{"role": t["role"], "contents": t["contents"][0]["text"]} for t in msgs]
    msgs = [t for t in msgs if (t["role"] != "system" or len(t["contents"]) > 0)]
    kw = dict(
        model=params.model,
        temperature=params.temperature,
        tools=tools_schema,
        messages=msgs,
    )
    return kw


def reconstruct_tools_schema(toolsets: list[str]) -> object:
    result = []
    for toolset in toolsets:
        for tool in all_tools[toolset]:
            result.append(chatlas._tools.func_to_schema(tool))

    return result


def reconstruct_message(turn: MyTurn) -> object:
    return dict(
        role=turn.role,
        contents=[reconstruct_content(content) for content in turn.contents],
    )


def reconstruct_content(content: list[chatlas._content.Content]) -> object:
    return str(content)


def reconstruct_response_traces(turn: MyTurn) -> object:
    # role: Literal["user", "assistant", "system"]
    # contents: list[ContentUnion] = Field(default_factory=list)
    # tokens: Optional[tuple[int, int]] = None
    # finish_reason: Optional[str] = None
    # completion: Optional[CompletionT] = Field(default=None, exclude=True)

    # model_config = ConfigDict(arbitrary_types_allowed=True)

    assert turn.role == "assistant"

    return {
        "choices": [
            {"message": reconstruct_message(turn), "finish_reason": turn.finish_reason}
        ]
    }


app = App(
    app_ui, server, bookmark_store="url", static_assets=Path(__file__).parent / "www"
)
