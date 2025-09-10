import json

from htmltools import css, tags
from pyhere import here
from shiny import App, render, ui
from shiny._utils import rand_hex

# Load recipes data
recipes_path = here("data/recipes/recipes.json")
with open(recipes_path, "r") as f:
    recipes = json.load(f)


def ui_ingredients(ingredients):
    """Generate HTML for ingredients list"""
    items = []
    for ingredient in ingredients:
        content = [str(ingredient["quantity"])]

        if ingredient.get("unit"):
            content.append(" " + ingredient["unit"])

        content.append(tags.strong(" " + ingredient["name"]))

        if ingredient.get("notes") and ingredient["notes"] != "":
            content.append(f" ({ingredient['notes']})")

        id = rand_hex(8)
        content = tags.input(
            tags.label(
                *content,
                **{"for": id, "class": "form-check-label", "style": "margin-left:8px;"},
            ),
            **{"type": "checkbox", "id": id, "class": "form-check-input"},
        )
        items.append(tags.li(content))

    return tags.ul(
        *items,
        style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:8px;",
    )


def ui_instructions(instructions):
    """Generate HTML for instructions list"""
    items = [tags.li(instruction) for instruction in instructions]
    return tags.ol(*items)


def ui_recipe(recipe):
    """Generate HTML for complete recipe card"""
    # Build ingredients section
    ingredients_content = ui.tags.div(
        tags.blockquote(recipe["description"]),
        ui_ingredients(recipe["ingredients"]),
        class_="overflow-auto",
    )
    ingredients_content = ui.fill.as_fill_item(ingredients_content)

    # Add image if available
    layout_content = [ingredients_content]

    if recipe.get("image_url") and recipe["image_url"] != "":
        image_div = tags.div(
            style=css(
                background_image=f"url('{recipe['image_url']}')",
                background_size="cover",
                background_position="center",
                height="100%",
                width="100%",
            )
        )
        layout_content.append(image_div)

    return ui.card(
        ui.card_header(recipe["title"], class_="text-bg-dark"),
        ui.card(
            ui.card_header("Ingredients"),
            ui.layout_columns(*layout_content),
            height=400,
        ),
        ui.card(
            ui.card_header("Instructions"),
            ui_instructions(recipe["instructions"]),
            height=400,
            max_height="max-content",
        ),
        fillable=True,
        fill=True,
    )


# Create recipe choices for radio buttons
recipe_choices = [recipe["title"] for recipe in recipes]

app_ui = ui.page_sidebar(
    ui.sidebar(
        ui.input_radio_buttons(
            "recipes",
            ui.tags.strong("What's for lunch today?"),
            choices=recipe_choices,
        ),
        width=300,
    ),
    ui.output_ui("ui_recipe_card", fillable=True),
    title="My Recipe Collection",
    fillable=True,
)


def server(input, output, session):
    @output
    @render.ui
    def ui_recipe_card():
        if not input.recipes():
            return ""

        # Find the selected recipe
        selected_recipe = None
        for recipe in recipes:
            if recipe["title"] == input.recipes():
                selected_recipe = recipe
                break

        if selected_recipe:
            return ui_recipe(selected_recipe)
        return ""


app = App(app_ui, server)
