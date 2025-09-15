# %%
from math import floor, sqrt

import chatlas
import dotenv
import numpy as np
from matplotlib import pyplot as plt
from plotnine import aes, geom_point, ggplot, labs, theme_bw

dotenv.load_dotenv()

# %%
m = 32

g = floor(sqrt(m))
u = (np.arange(1, g + 1) - 0.5) / g
xx, yy = np.meshgrid(u, u)
grid = np.column_stack([xx.ravel(), yy.ravel()])

# small jitter to avoid perfect lattice, scaled to cell size
eps = 1.0 / (2.0 * sqrt(m))
jitter = np.random.uniform(-eps, eps, size=grid.shape)
grid_jitter = np.clip(grid + jitter, 0.0, 1.0)

x = grid_jitter[:, 0]
y = grid_jitter[:, 1]

p = (
    ggplot(aes(x=x, y=y))
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
    "Interpret this plot of mtcars.",
    chatlas.content_image_plot(),
)
