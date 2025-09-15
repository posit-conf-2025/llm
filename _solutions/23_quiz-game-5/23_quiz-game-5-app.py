from typing import TypedDict

import chatlas
import dotenv
import polars as pl
from faicons import icon_svg
from pyhere import here
from shiny import App, reactive, render, ui

dotenv.load_dotenv()

# UI ---------------------------------------------------------------------------

app_ui = ui.page_sidebar(
    ui.sidebar(
        ui.value_box(
            "Correct Answers",
            ui.output_text("txt_correct"),
            showcase=icon_svg("circle-check"),
            theme="success",
        ),
        ui.value_box(
            "Incorrect Answers",
            ui.output_text("txt_incorrect"),
            showcase=icon_svg("circle-xmark"),
            theme="danger",
        ),
        position="right",
        fillable=True,
        width=400,
    ),
    ui.navset_card_underline(
        ui.nav_panel(
            "Quiz Game",
            ui.chat_ui("chat"),
        ),
        ui.nav_panel(
            "Your Answers",
            ui.output_data_frame("tbl_score"),
        ),
    ),
    title="Quiz Game 5",
    fillable=True,
)


class QuestionAnswer(TypedDict):
    theme: str
    question: str
    answer: str
    your_answer: str
    is_correct: bool


def server(input, output, session):
    chat_ui = ui.Chat(id="chat")

    # Set up the chat instance
    client = chatlas.ChatAnthropic(
        model="claude-3-7-sonnet-20250219",
        # Use your quiz game system prompt, or switch to _solutions to use ours
        system_prompt=f"""
{here("_solutions/14_quiz-game-1/prompt.md").read_text()}

After every question, use the "Update Score" tool to keep track of the user's
score. Be sure to call the tool after you have graded the user's final answer to
the question.
""",
    )

    scores = reactive.value[list[QuestionAnswer]]([])

    @render.data_frame
    def tbl_score():
        df = pl.DataFrame(scores())
        return df

    @render.text
    def txt_correct() -> int:
        return len([d for d in scores() if d["is_correct"]])

    @render.text
    def txt_incorrect() -> int:
        return len([d for d in scores() if not d["is_correct"]])

    def update_score(
        theme: str,
        question: str,
        answer: str,
        your_answer: str,
        is_correct: bool,
    ):
        """
        Add a correct or incorrect answer to the score. Call this tool after
        you've graded the user's answer to a question.

        Parameters
        ----------
        theme: The theme of the round.
        question: The quiz question that was asked.
        answer: The correct answer to the question.
        your_answer: The user's answer to the question.
        is_correct: Whether the user's answer was correct.
        """
        with reactive.isolate():
            val_scores = scores.get()

        answer = QuestionAnswer(
            theme=theme,
            question=question,
            answer=answer,
            your_answer=your_answer,
            is_correct=is_correct,
        )

        val_scores = [*val_scores, answer]
        scores.set(val_scores)

        correct = len([d for d in val_scores if d["is_correct"]])
        incorrect = len(val_scores) - correct
        return {"correct": correct, "incorrect": incorrect}

    client.register_tool(
        update_score,
        annotations={
            "title": "Update Score",
            "extra": {"icon": icon_svg("circle-plus")},
        },
    )

    @chat_ui.on_user_submit
    async def handle_user_input(user_input: str):
        response = await client.stream_async(user_input, content="all")
        await chat_ui.append_message_stream(response)

    @reactive.effect
    def _():
        chat_ui.update_user_input(value="Let's play the quiz game!", submit=True)


app = App(app_ui, server)
