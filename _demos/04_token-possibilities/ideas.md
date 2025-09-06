The goal of this exercise is to explore how the words you use in your prompt change the possible responses from a Large Language Model (LLM).

We start with a specific, but open-ended prompt for a limerick about a cat.

```markdown
Write a funny limerick about a cat.
```

Try replacing `cat` with `animal`.

```markdown
Write a funny limerick about an animal.
```

How does that change the LLM's response?
Try adding adjectives or other modifiers – `barn animal`, `zoo animal`, `funny animal` – to see how they affect the output.

***

## Other prompt ideas to explore

Try these examples to explore how LLMs navigate between certainty and ambiguity based on available context.

### High Ambiguity Examples

- "The bank..." (financial institution or riverside?)
- "She saw a bat..." (animal or sports equipment?)
- "I need to get a prescription for my..." (many medical possibilities)
- "Please pass the..." (countless objects could follow)
- "The doctor examined the patient's..." (multiple body parts possible)

### Context Shifts Probability

- "I'm going to the bank to..." (now likely financial)
- "I'm going to the bank to fish..." (now likely riverside)
- "The pitcher threw the bat..." (sports context established)
- "The cave was full of sleeping bat..." (animal context established)
- "Time flies like an..." (arrow? airplane? hour?)
- "Time flies like an arrow; fruit flies like a..." (banana becomes highly probable)

### Probability Steered by Specificity

- "The capital of France is..." (very high certainty for "Paris")
- "The chemical symbol for gold is..." (very high certainty for "Au")
- "To be or not to be, that is the..." (extremely high certainty for "question")
- "I woke up this morning feeling..." (many plausible completions)
- "In a world where..." (extremely open-ended)

### Contextual Collocations

- "Strong..." (coffee? winds? opinions? person?)
- "Strong tea and..." (likely food-related completions)
- "The heavy..." (weight? rain? traffic? burden?)
- "She couldn't bear the heavy..." (psychological interpretation more likely)
