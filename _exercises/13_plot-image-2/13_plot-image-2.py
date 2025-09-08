# %%
from math import floor, sqrt

import chatlas
import dotenv
import matplotlib.pyplot as plt
import numpy as np

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

plt.figure(figsize=(7, 5))
plt.scatter(x, y, color="steelblue", s=30, edgecolor="white", linewidth=0.5)
plt.title("MPG vs Weight")
plt.xlabel("Weight (1000 lb)")
plt.ylabel("Miles per Gallon (mpg)")
plt.tight_layout()
plt.show()

# %%
chat = chatlas.ChatAuto("openai/gpt-5")
chat.chat(
    "Interpret this plot.",
    chatlas.content_image_plot(),
)
