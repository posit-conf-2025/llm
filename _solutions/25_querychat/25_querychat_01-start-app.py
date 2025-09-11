# Setup ------------------------------------------------------------------------
import pandas as pd
import plotly.express as px
import querychat
import shinywidgets as sw
from faicons import icon_svg
from pyhere import here
from shiny import App, reactive, render, ui

# Load and prepare data
airbnb_data = (
    pd.read_csv(here("data/airbnb-asheville.csv"))
    .loc[lambda df: df["price"].notnull()]
    .assign(occupancy_pct=lambda df: (365 - df["availability_365"]) / 365)
)

room_type_choices = sorted(airbnb_data["room_type"].dropna().unique().tolist())
neighborhood_choices = airbnb_data["neighborhood"].dropna().unique().tolist()

# Step 1: Set up querychat ----------
# Configure querychat. This is where you specify the dataset and can also
# override options like the greeting message, system prompt, model, etc.
# airbnb_qc_config = ____

# UI ===------------------------------------------------------------------------
app_ui = ui.page_sidebar(
    # Step 2: Replace sidebar ----
    # Replace the entire sidebar with querychat.sidebar("airbnb")
    ui.sidebar(
        ui.input_checkbox_group(
            "room_type",
            "Room Type",
            choices=room_type_choices,
            selected=room_type_choices,
        ),
        ui.input_selectize(
            "neighborhood", "Neighborhood", choices=neighborhood_choices, multiple=True
        ),
        ui.input_slider(
            "price",
            "Price Range",
            min=0,
            max=7000,
            value=[0, 7000],
            step=50,
            pre="$",
        ),
    ),
    # Extra UI added when you add in querychat
    ui.card(
        ui.card_body(
            ui.navset_card_underline(
                ui.nav_spacer(),
                ui.nav_panel(
                    "SQL",
                    ui.output_ui("ui_sql"),
                    icon=icon_svg("terminal"),
                ),
                ui.nav_panel(
                    "Table",
                    ui.output_data_frame("table"),
                    icon=icon_svg("table"),
                ),
            ),
            padding=0,
        ),
        fill=False,
        max_height="400px",
        full_screen=True,
    )
    if "airbnb_qc_config" in globals()
    else None,
    # Value boxes ----
    ui.layout_columns(
        ui.value_box(
            "Number of Listings",
            ui.output_text("num_listings"),
            showcase=icon_svg("house"),
        ),
        ui.value_box(
            "Average Price per Night",
            ui.output_text("avg_price"),
            showcase=icon_svg("dollar-sign"),
        ),
        ui.value_box(
            "Average Occupancy",
            ui.output_text("avg_occupancy"),
            showcase=icon_svg("calendar-check"),
        ),
        fill=False,
    ),
    # Cards ----
    ui.layout_columns(
        ui.card(
            ui.card_body(sw.output_widget("listings_map", fill=True), padding=0),
            full_screen=True,
        ),
        ui.layout_columns(
            ui.card(
                ui.card_header("Room Types"),
                sw.output_widget("room_type_plot"),
                full_screen=True,
            ),
            ui.card(
                ui.card_header("Availability by Room Type"),
                sw.output_widget("availability_plot"),
                full_screen=True,
            ),
            col_widths=12,
        ),
        min_height="400px",
    ),
    title="Asheville Airbnb Dashboard",
    class_="bslib-page-dashboard",
    fillable=True,
)


# Server -----------------------------------------------------------------------
def server(input, output, session):
    # Step 3: Set up querychat server ----
    # Create an `airbnb_qc` querychat object by calling `querychat.server()`
    # with the same ID and config from steps 2 and 1.
    # airbnb_qc = ____

    # Step 4: Use the querychat-filtered data ----
    # Replace all of the logic inside of `filtered_data()` with
    # `airbnb_qc.df()`
    @reactive.calc
    def filtered_data():
        df = airbnb_data.copy()

        # Room type filter
        room_type = input.room_type()
        if room_type:
            df = df[df["room_type"].isin(room_type)]

        # Neighborhood filter
        neighborhoods = input.neighborhood()
        if neighborhoods:
            df = df[df["neighborhood"].isin(neighborhoods)]

        # Price range filter
        pmin, pmax = input.price()
        df = df[(df["price"] >= pmin) & (df["price"] <= pmax)]

        return df

    @render.text
    def num_listings():
        return f"{len(filtered_data()):,}"

    @render.text
    def avg_price():
        df = filtered_data()
        if df.empty:
            return "N/A"
        mean_price = df["price"].mean()
        return f"${mean_price:.2f}"

    @render.text
    def avg_occupancy():
        df = filtered_data()
        if df.empty:
            return "N/A"
        mean_occ = df["occupancy_pct"].mean()
        return f"{mean_occ:.1%}"

    @sw.render_widget
    def room_type_plot():
        df = filtered_data()
        if df.empty:
            return None

        df = df[df["price"].notnull()]

        fig = px.histogram(
            df,
            x="price",
            color="room_type",
            barmode="group",
            nbins=10,
            labels={"price": "Price", "room_type": "Room Type"},
            template="simple_white",
        )
        fig.update_layout(showlegend=True, font_size=14)
        fig.update_yaxes(title_text="Count")
        fig.update_xaxes()
        fig.update_layout(margin=dict(l=0, r=0, t=0, b=0))
        return fig

    @sw.render_widget
    def availability_plot():
        df = filtered_data()
        if df.empty:
            return None
        pdf = df[["availability_365", "room_type"]]
        fig = px.box(
            pdf,
            x="availability_365",
            y="room_type",
            labels={"availability_365": "Availability (days/year)", "room_type": ""},
            template="simple_white",
        )
        fig.update_layout(showlegend=False, font_size=14)
        return fig

    @sw.render_widget
    def listings_map():
        df = filtered_data()
        if df.empty:
            return None
        pdf = df[
            [
                "latitude",
                "longitude",
                "name",
                "price",
                "room_type",
                "neighborhood",
                "host_name",
                "n_reviews",
                "availability_365",
            ]
        ]

        fig = px.scatter_mapbox(
            pdf,
            lat="latitude",
            lon="longitude",
            zoom=11,
        )
        fig.update_traces(
            hovertemplate=(
                "<b>%{customdata[0]}</b><br>"
                "Price: $%{customdata[1]:.2f}<br>"
                "Room type: %{customdata[2]}<br>"
                "Neighborhood: %{customdata[3]}<br>"
                "Host: %{customdata[4]}<br>"
                "Reviews: %{customdata[5]:,}<br>"
                "Availability: %{customdata[6]} days/yr"
                "<extra></extra>"
            ),
            customdata=pdf[
                [
                    "name",
                    "price",
                    "room_type",
                    "neighborhood",
                    "host_name",
                    "n_reviews",
                    "availability_365",
                ]
            ].to_numpy(),
        )

        fig.update_layout(
            mapbox_style="open-street-map", margin=dict(l=0, r=0, t=0, b=0)
        )
        return fig

    if "airbnb_qc_config" in globals():

        @render.ui
        def ui_sql():
            sql = airbnb_qc.sql() if airbnb_qc.sql() else "SELECT * FROM airbnb_data"

            return ui.pre(ui.code(sql))

        @render.data_frame
        def table():
            return airbnb_qc.df()


app = App(app_ui, server)
