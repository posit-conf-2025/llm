# %%
import chatlas
import dotenv
import polars as pl
from matplotlib import pyplot as plt
from plotnine import aes, geom_point, ggplot, labs, theme_bw
from pyhere import here

dotenv.load_dotenv()

# %% [markdown]
# Step 1: Create a scatter plot of `mpg` vs `wt` from the `mtcars` dataset using
# `plotnine`.

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

# %% [markdown]
# Step 2: Ask Claude 4 Sonnet to interpret the plot.
# (Hint: see `content_image_...`)

# %%
chat = chatlas.ChatAuto("____")
chat.chat(
    "Interpret this plot.",
    chatlas.____(),
)
