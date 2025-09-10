``` python
import polars as pl
import polars.selectors as cs
import seaborn as sbn
import matplotlib.pyplot as plt

# Make the graphs a bit prettier, and bigger
plt.style.use('ggplot')
plt.rcParams['figure.figsize'] = (15, 5)

print(pl.__version__)
```

    1.6.0

# 1.1 Reading data from a csv file

You can read data from a CSV file using the `read_csv` function. By
default, it assumes that the fields are comma-separated.

We\'re going to be looking some cyclist data from Montréal. Here\'s the
[original
page](http://donnees.ville.montreal.qc.ca/dataset/velos-comptage) (in
French), but it\'s already included in this repository. We\'re using the
data from 2012.

This dataset is a list of how many people were on 7 different bike paths
in Montreal, each day.

``` python
broken_df = pl.read_csv('../data/bikes.csv',encoding = "ISO-8859-1")
broken_df.head(3)
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 1)</small><table border="1" class="dataframe"><thead><tr><th>Date;Berri 1;Brébeuf (données non disponibles);Côte-Sainte-Catherine;Maisonneuve 1;Maisonneuve 2;du Parc;Pierre-Dupuy;Rachel1;St-Urbain (données non disponibles)</th></tr><tr><td>str</td></tr></thead><tbody><tr><td>&quot;01/01/2012;35;;0;38;51;26;10;1…</td></tr><tr><td>&quot;02/01/2012;83;;1;68;153;53;6;4…</td></tr><tr><td>&quot;03/01/2012;135;;2;104;248;89;3…</td></tr></tbody></table></div>

You\'ll notice that this is totally broken! `read_csv` has a bunch of
options that will let us fix that, though. Here we\'ll

- change the column separator to a `;`
- Set the encoding to `'latin1'` (the default is `'utf8'`)
- Attempt to parse all date columns
- Explicitly set the datatype of two non-populated columns in the CSV
  sheet

``` python
fixed_df = pl.read_csv('../data/bikes.csv',
                       separator=';',
                       encoding='latin1',
                       try_parse_dates=True,
                       schema_overrides={'Brébeuf (données non disponibles)': pl.Int64,
                               'St-Urbain (données non disponibles)': pl.Int64}
)
fixed_df.head(3)
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 10)</small><table border="1" class="dataframe"><thead><tr><th>Date</th><th>Berri 1</th><th>Brébeuf (données non disponibles)</th><th>Côte-Sainte-Catherine</th><th>Maisonneuve 1</th><th>Maisonneuve 2</th><th>du Parc</th><th>Pierre-Dupuy</th><th>Rachel1</th><th>St-Urbain (données non disponibles)</th></tr><tr><td>date</td><td>i64</td><td>i64</td><td>i64</td><td>i64</td><td>i64</td><td>i64</td><td>i64</td><td>i64</td><td>i64</td></tr></thead><tbody><tr><td>2012-01-01</td><td>35</td><td>null</td><td>0</td><td>38</td><td>51</td><td>26</td><td>10</td><td>16</td><td>null</td></tr><tr><td>2012-01-02</td><td>83</td><td>null</td><td>1</td><td>68</td><td>153</td><td>53</td><td>6</td><td>43</td><td>null</td></tr><tr><td>2012-01-03</td><td>135</td><td>null</td><td>2</td><td>104</td><td>248</td><td>89</td><td>3</td><td>58</td><td>null</td></tr></tbody></table></div>

# 1.2 Selecting a column

When you read a CSV, you get a kind of object called a `DataFrame`,
which is made up of rows and columns. You get columns out of a DataFrame
the same way you get elements out of a dictionary.

Here\'s an example:

``` python
fixed_df['Berri 1']
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (310,)</small><table border="1" class="dataframe"><thead><tr><th>Berri 1</th></tr><tr><td>i64</td></tr></thead><tbody><tr><td>35</td></tr><tr><td>83</td></tr><tr><td>135</td></tr><tr><td>144</td></tr><tr><td>197</td></tr><tr><td>&hellip;</td></tr><tr><td>2405</td></tr><tr><td>1582</td></tr><tr><td>844</td></tr><tr><td>966</td></tr><tr><td>2247</td></tr></tbody></table></div>

# 1.3 Plotting a column

We can see that, unsurprisingly, not many people are biking in January,
February, and March,

``` python
sbn.lineplot(fixed_df, x='Date', y='Berri 1')
```

    <Axes: xlabel='Date', ylabel='Berri 1'>

![png](Chapter%201%20-%20Reading%20from%20a%20CSV_files/Chapter%201%20-%20Reading%20from%20a%20CSV_11_1.png)

We can also plot all the columns just as easily. We\'ll make it a little
bigger, too. You can see that it\'s more squished together, but all the
bike paths behave basically the same \-- if it\'s a bad day for
cyclists, it\'s a bad day everywhere.

``` python
melt_df = fixed_df.unpivot(index='Date', variable_name='trail', value_name='distance')

with plt.rc_context({'figure.figsize': (15, 10)}):
    sbn.lineplot(melt_df, x='Date', y='distance', hue='trail')
```

![png](Chapter%201%20-%20Reading%20from%20a%20CSV_files/Chapter%201%20-%20Reading%20from%20a%20CSV_13_0.png)

# 1.4 Putting all that together

Here\'s the code we needed to write do draw that graph, all together:

``` python
fixed_df = pl.read_csv('../data/bikes.csv', separator=';', encoding='latin1', try_parse_dates=True)
sbn.lineplot(fixed_df, x='Date', y='Berri 1')
```

    <Axes: xlabel='Date', ylabel='Berri 1'>

![png](Chapter%201%20-%20Reading%20from%20a%20CSV_files/Chapter%201%20-%20Reading%20from%20a%20CSV_16_1.png)

<style>
    @font-face {
        font-family: "Computer Modern";
        src: url('http://mirrors.ctan.org/fonts/cm-unicode/fonts/otf/cmunss.otf');
    }
    div.cell{
        width:800px;
        margin-left:16% !important;
        margin-right:auto;
    }
    h1 {
        font-family: Helvetica, serif;
    }
    h4{
        margin-top:12px;
        margin-bottom: 3px;
       }
    div.text_cell_render{
        font-family: Computer Modern, "Helvetica Neue", Arial, Helvetica, Geneva, sans-serif;
        line-height: 145%;
        font-size: 130%;
        width:800px;
        margin-left:auto;
        margin-right:auto;
    }
    .CodeMirror{
            font-family: "Source Code Pro", source-code-pro,Consolas, monospace;
    }
    .text_cell_render h5 {
        font-weight: 300;
        font-size: 22pt;
        color: #4057A1;
        font-style: italic;
        margin-bottom: .5em;
        margin-top: 0.5em;
        display: block;
    }
    &#10;    .warning{
        color: rgb( 240, 20, 20 )
        }  
&#10;
&#10;
&#10;
&#10;
