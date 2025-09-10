## Databot Demo

```
Let's look at `data/all_recipes.csv`, do some basic work to familiarize ourselves with the data, and then find recipes that are reasonably fast to cook, don't require too many ingredients or steps, and get the best ratings.
```

If the app tries to use `tidyverse`, it will fail because it's not installed. Instead, it should use `data.table` or `dplyr` (both are installed).

```
Just use dplyr, readr, ggplot2, tidyr, etc. directly
```

Databot probably finds recipes that are super fast to cook but not very nutritional.

```
but I want something nutritional, not just that it minimizes cooking time and ingredients
```

Ask follow up questions about how it calculates nutrition, e.g. what is `macro_balance_score`?
And make sure that it doesn't drop cooking time completely.

```
Have we lost cooking time?
```

And then make some plots to visualize the tradeoffs.

```
Let's make a few plots that summarize the stats and tradeoffs between nutrition, cooking time, and number of ingredients
```

Finally, ask Databot to write a summary of what we found.

```
Write a report summarizing our calculations and findings.
Include name, link, author and ingredients for the top 5 healthy weeknight recipes.
```
