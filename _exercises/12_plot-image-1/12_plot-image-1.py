# %%
import chatlas
import dotenv
import polars as pl
import matplotlib.pyplot as plt
from pyhere import here

dotenv.load_dotenv()

# %%
mtcars = pl.read_csv(here("data/mtcars.csv"))
mtcars

# %%
x = mtcars["wt"].to_numpy()
y = mtcars["mpg"].to_numpy()

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
