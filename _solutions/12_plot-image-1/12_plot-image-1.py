# %%
import chatlas
import dotenv
import polars as pl
from matplotlib import pyplot as plt
from plotnine import aes, geom_point, ggplot, labs, theme_bw
from pyhere import here

dotenv.load_dotenv()

# %%
mtcars = pl.read_csv(here("data/mtcars.csv"))
mtcars

# %%
p = (
    ggplot(mtcars, aes(x="wt", y="mpg"))
    + geom_point(color="steelblue", size=2)
    + labs(title="MPG vs Weight", x="Weight (1000 lb)", y="Miles per Gallon (mpg)")
    + theme_bw()
)

p.show()

# %%
# Register the plot with matplotlib's current figure
plt.figure(p.draw())

chat = chatlas.ChatAuto("anthropic/claude-sonnet-4-20250514")
chat.chat(
    "Interpret this plot.",
    chatlas.content_image_plot(),
)
