# %%
import chatlas
import dotenv
import polars as pl
from plotnine import ggplot, aes, geom_point, labs, theme_bw
from pyhere import here

dotenv.load_dotenv()

# %%
mtcars = pl.read_csv(here("data/mtcars.csv"))
mtcars

# %%
p = (
    ggplot(mtcars, aes(x="wt", y="mpg"))
    + geom_point(color="steelblue", size=2)
    + labs(
        title="MPG vs Weight",
        x="Weight (1000 lb)",
        y="Miles per Gallon (mpg)"
    )
    + theme_bw()
)

p.show()

# %%
chat = chatlas.ChatAuto("openai/gpt-5")
chat.chat(
    "Interpret this plot.",
    chatlas.content_image_plot(),
)
