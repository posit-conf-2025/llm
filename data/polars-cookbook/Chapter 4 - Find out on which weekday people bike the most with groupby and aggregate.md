```python
import polars as pl
import polars.selectors as cs
import seaborn as sbn
import matplotlib.pyplot as plt

plt.style.use('ggplot')
plt.rcParams['figure.figsize'] = (15, 5)
print(pl.__version__)
```

    1.6.0


Okay! We're going back to our bike path dataset here. I live in Montreal, and I was curious about whether we're more of a commuter city or a biking-for-fun city -- do people bike more on weekends, or on weekdays?

# 4.1 Adding a 'weekday' column to our dataframe

First, we need to load up the data. We've done this before.


```python
bikes = pl.read_csv('../data/bikes.csv', separator=';', encoding='latin1', try_parse_dates=True)
bikes.plot.line(x='Date', y='Berri 1').properties(width='container')
sbn.lineplot(bikes, x='Date', y='Berri 1')
```




    <Axes: xlabel='Date', ylabel='Berri 1'>




    
![png](Chapter%204%20-%20Find%20out%20on%20which%20weekday%20people%20bike%20the%20most%20with%20groupby%20and%20aggregate_files/Chapter%204%20-%20Find%20out%20on%20which%20weekday%20people%20bike%20the%20most%20with%20groupby%20and%20aggregate_4_1.png)
    


Next up, we're just going to look at the Berri bike path. Berri is a street in Montreal, with a pretty important bike path. I use it mostly on my way to the library now, but I used to take it to work sometimes when I worked in Old Montreal. 

So we're going to create a dataframe with just the Berri bikepath in it


```python
berri_bikes = bikes.select('Date', 'Berri 1')
```


```python
berri_bikes.head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 2)</small><table border="1" class="dataframe"><thead><tr><th>Date</th><th>Berri 1</th></tr><tr><td>date</td><td>i64</td></tr></thead><tbody><tr><td>2012-01-01</td><td>35</td></tr><tr><td>2012-01-02</td><td>83</td></tr><tr><td>2012-01-03</td><td>135</td></tr><tr><td>2012-01-04</td><td>144</td></tr><tr><td>2012-01-05</td><td>197</td></tr></tbody></table></div>



Next, we need to add a 'weekday' column. Firstly, we can get the weekday from the `Date` column. It's basically all the days of the year.


```python
berri_bikes['Date']
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (310,)</small><table border="1" class="dataframe"><thead><tr><th>Date</th></tr><tr><td>date</td></tr></thead><tbody><tr><td>2012-01-01</td></tr><tr><td>2012-01-02</td></tr><tr><td>2012-01-03</td></tr><tr><td>2012-01-04</td></tr><tr><td>2012-01-05</td></tr><tr><td>&hellip;</td></tr><tr><td>2012-11-01</td></tr><tr><td>2012-11-02</td></tr><tr><td>2012-11-03</td></tr><tr><td>2012-11-04</td></tr><tr><td>2012-11-05</td></tr></tbody></table></div>



You can see that actually some of the days are missing -- only 310 days of the year are actually there. Who knows why.

Polars has a bunch of really great time series functionality, so if we wanted to get the day of the month for each row, we could do it like this:


```python
berri_bikes['Date'].dt.ordinal_day()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (310,)</small><table border="1" class="dataframe"><thead><tr><th>Date</th></tr><tr><td>i16</td></tr></thead><tbody><tr><td>1</td></tr><tr><td>2</td></tr><tr><td>3</td></tr><tr><td>4</td></tr><tr><td>5</td></tr><tr><td>&hellip;</td></tr><tr><td>306</td></tr><tr><td>307</td></tr><tr><td>308</td></tr><tr><td>309</td></tr><tr><td>310</td></tr></tbody></table></div>



We actually want the weekday, though:


```python
berri_bikes['Date'].dt.weekday()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (310,)</small><table border="1" class="dataframe"><thead><tr><th>Date</th></tr><tr><td>i8</td></tr></thead><tbody><tr><td>7</td></tr><tr><td>1</td></tr><tr><td>2</td></tr><tr><td>3</td></tr><tr><td>4</td></tr><tr><td>&hellip;</td></tr><tr><td>4</td></tr><tr><td>5</td></tr><tr><td>6</td></tr><tr><td>7</td></tr><tr><td>1</td></tr></tbody></table></div>



These are the days of the week, where 1 is Monday. I found out that 1 was Monday from the [documentation](https://pola-rs.github.io/polars/py-polars/html/reference/expressions/api/polars.Expr.dt.weekday.html#polars.Expr.dt.weekday).

Now that we know how to *get* the weekday, we can add it as a column in our dataframe using the `df.with_columns` function. This function behaves a lot like `df.select` except that it also preserves the original columns of the DataFrame (overwriting any re-defined columns).


```python
berri_bikes = berri_bikes.with_columns(
    weekday = pl.col('Date').dt.weekday()
)
berri_bikes.head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 3)</small><table border="1" class="dataframe"><thead><tr><th>Date</th><th>Berri 1</th><th>weekday</th></tr><tr><td>date</td><td>i64</td><td>i8</td></tr></thead><tbody><tr><td>2012-01-01</td><td>35</td><td>7</td></tr><tr><td>2012-01-02</td><td>83</td><td>1</td></tr><tr><td>2012-01-03</td><td>135</td><td>2</td></tr><tr><td>2012-01-04</td><td>144</td><td>3</td></tr><tr><td>2012-01-05</td><td>197</td><td>4</td></tr></tbody></table></div>



# 4.2 Adding up the cyclists by weekday

This turns out to be really easy!

Dataframes have a `.group_by()` method that is similar to SQL groupby, if you're familiar with that. I'm not going to explain more about it right now -- if you want to to know more, [the documentation](https://pola-rs.github.io/polars/py-polars/html/reference/dataframe/api/polars.DataFrame.groupby.html) is really good.

In this case, `berri_bikes.group_by('weekday').agg(sum)` means "Group the rows by weekday and then add up all the values with the same weekday".


```python
weekday_counts = (
    berri_bikes
    .group_by('weekday')
    .agg(pl.col('Berri 1').sum())
    .sort('weekday')
)
weekday_counts
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (7, 2)</small><table border="1" class="dataframe"><thead><tr><th>weekday</th><th>Berri 1</th></tr><tr><td>i8</td><td>i64</td></tr></thead><tbody><tr><td>1</td><td>134298</td></tr><tr><td>2</td><td>135305</td></tr><tr><td>3</td><td>152972</td></tr><tr><td>4</td><td>160131</td></tr><tr><td>5</td><td>141771</td></tr><tr><td>6</td><td>101578</td></tr><tr><td>7</td><td>99310</td></tr></tbody></table></div>



It's hard to remember what 1, 2, 3, 4, 5, 6, 7 mean, so we can fix it up and graph it:


```python
days_df = pl.DataFrame(
    data={
        "weekday" :range(1, 8),
        "weekday_name": ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    },
    schema_overrides={'weekday':pl.Int8} # Make sure the type matches our weekday_counts dataframe
)
weekday_counts = weekday_counts.join(days_df, on='weekday')
weekday_counts
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (7, 3)</small><table border="1" class="dataframe"><thead><tr><th>weekday</th><th>Berri 1</th><th>weekday_name</th></tr><tr><td>i8</td><td>i64</td><td>str</td></tr></thead><tbody><tr><td>1</td><td>134298</td><td>&quot;Monday&quot;</td></tr><tr><td>2</td><td>135305</td><td>&quot;Tuesday&quot;</td></tr><tr><td>3</td><td>152972</td><td>&quot;Wednesday&quot;</td></tr><tr><td>4</td><td>160131</td><td>&quot;Thursday&quot;</td></tr><tr><td>5</td><td>141771</td><td>&quot;Friday&quot;</td></tr><tr><td>6</td><td>101578</td><td>&quot;Saturday&quot;</td></tr><tr><td>7</td><td>99310</td><td>&quot;Sunday&quot;</td></tr></tbody></table></div>




```python
sbn.barplot(weekday_counts, x='weekday_name', y='Berri 1')
```




    <Axes: xlabel='weekday_name', ylabel='Berri 1'>




    
![png](Chapter%204%20-%20Find%20out%20on%20which%20weekday%20people%20bike%20the%20most%20with%20groupby%20and%20aggregate_files/Chapter%204%20-%20Find%20out%20on%20which%20weekday%20people%20bike%20the%20most%20with%20groupby%20and%20aggregate_21_1.png)
    


So it looks like Montrealers are commuter cyclists -- they bike much more during the week. Neat!

# 4.3 Putting it together

We scan and join the dataframes in lazy mode so data is only computed when requred by the process.


```python
# scan_csv is lazy method that optimizes query only once data is needed to plot.
bikes = pl.scan_csv('../data/bikes.csv', separator=';', encoding='utf8', try_parse_dates=True)

# get weekday data for Berri 1 path
berri_bikes = bikes.select('Berri 1', weekday = pl.col('Date').dt.weekday())

# Add up the number of cyclists by weekday
weekday_counts = (
    berri_bikes.group_by('weekday')
    .agg(pl.col('Berri 1').sum())
    .join(days_df.lazy(), on='weekday')
    .sort('weekday')
)
sbn.barplot(weekday_counts.collect(), x='weekday_name', y='Berri 1')
```




    <Axes: xlabel='weekday_name', ylabel='Berri 1'>




    
![png](Chapter%204%20-%20Find%20out%20on%20which%20weekday%20people%20bike%20the%20most%20with%20groupby%20and%20aggregate_files/Chapter%204%20-%20Find%20out%20on%20which%20weekday%20people%20bike%20the%20most%20with%20groupby%20and%20aggregate_25_1.png)
    

