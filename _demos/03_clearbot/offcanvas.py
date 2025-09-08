# From https://github.com/jonkeane/shinyImages/blob/main/offcanvas.py

from typing import Literal

import icons
from shiny import ui


def offcanvas_ui(
    id: str,
    title: str,
    body: ui.TagChild,
    *,
    placement: Literal["start", "end", "top", "bottom"] = "end",
    **kwargs: str,
):
    """
    A simple wrapper of Bootstrap's offcanvas component
    https://getbootstrap.com/docs/5.3/components/offcanvas/#placement
    """
    label_id = f"{id}-label"
    return ui.div(
        {"class": "offcanvas-container"},
        # offcanvas_icon_button(id),
        ui.div(
            {
                "class": f"offcanvas offcanvas-{placement}",
                "tabindex": "-1",
                "id": id,
                "aria-labelledby": label_id,
                **kwargs,
            },
            ui.div(
                {"class": "offcanvas-header"},
                ui.h5(title, {"class": "offcanvas-title", "id": label_id}),
                offcanvas_close_button(),
            ),
            ui.div({"class": "offcanvas-body"}, body),
        ),
    )


def offcanvas_icon_button(id: str):
    return ui.tags.span(
        {
            "class": "btn btn-sm btn-secondary",
            "type": "button",
            "data-bs-toggle": "offcanvas",
            "data-bs-target": f"#{id}",
            "aria-controls": id,
            "title": "Toggle offcanvas chat",
        },
        icons.hamburger,
    )


def offcanvas_close_button():
    return ui.tags.button(
        {
            "type": "button",
            "class": "btn-close",
            "data-bs-dismiss": "offcanvas",
            "aria-label": "Close",
        }
    )
