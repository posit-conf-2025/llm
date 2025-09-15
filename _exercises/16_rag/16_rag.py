# %%
import chatlas
import dotenv
from pyhere import here

dotenv.load_dotenv()

# %% [markdown]
# Python has a plethora of options for working with knowledge stores
# ([llama-index](https://docs.llamaindex.ai/en/stable/),
# [pinecone](https://docs.pinecone.io/reference/python-sdk), etc.). It doesn’t
# really matter which one you choose, but due to its popularity, maturity, and
# simplicity, lets demonstrate with the
# [`llama-index`](https://docs.llamaindex.ai/en/stable/) library.
#
# With `llama-index`, it’s easy to create a knowledge store from a wide variety
# of input formats, such as text files, [web
# pages](https://docs.llamaindex.ai/en/stable/examples/data_connectors/WebPageDemo/),
# and [much more](https://pypi.org/project/llama-index-readers-markitdown/).
#
# For this task, I've downloaded the notebook files in the [Polars
# Cookbook](https://github.com/escobar-west/polars-cookbook) and converted them
# to markdown. This snippet will ingest those markdown files files, embed them,
# and create a vector store `index` that is ready for
# [retrieval](https://posit-dev.github.io/chatlas/misc/RAG.html#retrieve-content).
#
# Creating the vector store index can take a while, so we write it to disk to
# persist between sessions.

# %%
from llama_index.core import SimpleDirectoryReader, VectorStoreIndex

polars_cookbook = here("data/polars-cookbook")
docs = SimpleDirectoryReader(polars_cookbook).load_data()
index = VectorStoreIndex.from_documents(docs)

index.storage_context.persist(
    persist_dir=here("_exercises/16_rag/polars_cookbook_index")
)

# %% [markdown]
# With our `index` now available on disk, we’re ready to implement
# `retrieve_polars_knowledge()` – a function that retrieves relevant content
# from the our Polars Cookbook knowledge store based on the user query.

# %%
from llama_index.core import StorageContext, load_index_from_storage

index_polars_cookbook = here("_exercises/16_rag/polars_cookbook_index")
storage_context = StorageContext.from_defaults(persist_dir=index_polars_cookbook)
index = load_index_from_storage(storage_context)


def retrieve_polars_knowledge(query: str) -> list[str]:
    """
    Retrieve relevant content from the Polars Cookbook knowledge store based on
    the user query.

    Parameters
    ----------
    query : str
        The user query to search for relevant Polars knowledge.
    """
    retriever = index.as_retriever(similarity_top_k=5)
    nodes = retriever.retrieve(query)
    return "\n\n".join([f"<excerpt>{x.text}</excerpt>" for x in nodes])


# %% [markdown]
# This particular implementation retrieves the top 5 most relevant documents
# from the `index` based on the user query, but you can adjust the number of
# results by changing the `similarity_top_k` parameter. There’s no magic number
# for this parameter, but `llama-index` defaults to 2, so you may want to
# increase it if you find that the retrieved content is too sparse or not
# relevant enough.
#
# Let's try this out now with a task:

# %%
task = """
How do I find all rows in a DataFrame which have the max value for count column, after grouping by ['Sp','Mt'] columns?

Example 1: the following DataFrame, which I group by ['Sp','Mt']:

```
Sp Mt Value count
0 MM1 S1 a 2
1 MM1 S1 n **3**
2 MM1 S3 cb **5**
3 MM2 S3 mk **8**
4 MM2 S4 bg **5**
5 MM2 S4 dgd 1
6 MM4 S2 rd 2
7 MM4 S2 cb 2
8 MM4 S2 uyi **7**
```

Expected output: get the result rows whose count is max in each group, like:

```
1 MM1 S1 n **3**
2 MM1 S3 cb **5**
3 MM2 S3 mk **8**
4 MM2 S4 bg **5**
8 MM4 S2 uyi **7**
```
"""

retrieve_polars_knowledge(task)

# %% [markdown]
# Finally, we can plug this retrieval function into a chatlas chatbot. Copy
# the task from the previous block and paste it into the chatbot to see how it
# works!

# %%
chat = chatlas.ChatAuto("openai/gpt-4.1-nano")

chat.register_tool(retrieve_polars_knowledge)

chat.app()
