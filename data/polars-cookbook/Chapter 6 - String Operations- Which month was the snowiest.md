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


We saw earlier that polars is really good at dealing with dates. It is also amazing with strings! We're going to go back to our weather data from Chapter 5, here.


```python
weather_2012 = pl.read_csv('../data/weather_2012.csv', try_parse_dates=True)
weather_2012.head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 8)</small><table border="1" class="dataframe"><thead><tr><th>Date/Time</th><th>Temp (C)</th><th>Dew Point Temp (C)</th><th>Rel Hum (%)</th><th>Wind Spd (km/h)</th><th>Visibility (km)</th><th>Stn Press (kPa)</th><th>Weather</th></tr><tr><td>datetime[μs]</td><td>f64</td><td>f64</td><td>i64</td><td>i64</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>2012-01-01 00:00:00</td><td>-1.8</td><td>-3.9</td><td>86</td><td>4</td><td>8.0</td><td>101.24</td><td>&quot;Fog&quot;</td></tr><tr><td>2012-01-01 01:00:00</td><td>-1.8</td><td>-3.7</td><td>87</td><td>4</td><td>8.0</td><td>101.24</td><td>&quot;Fog&quot;</td></tr><tr><td>2012-01-01 02:00:00</td><td>-1.8</td><td>-3.4</td><td>89</td><td>7</td><td>4.0</td><td>101.26</td><td>&quot;Freezing Drizzle,Fog&quot;</td></tr><tr><td>2012-01-01 03:00:00</td><td>-1.5</td><td>-3.2</td><td>88</td><td>6</td><td>4.0</td><td>101.27</td><td>&quot;Freezing Drizzle,Fog&quot;</td></tr><tr><td>2012-01-01 04:00:00</td><td>-1.5</td><td>-3.3</td><td>88</td><td>7</td><td>4.8</td><td>101.23</td><td>&quot;Fog&quot;</td></tr></tbody></table></div>



# 6.1 String operations

You'll see that the 'Weather' column has a text description of the weather that was going on each hour. We'll assume it's snowing if the text description contains "Snow".

polars provides vectorized string functions, to make it easy to operate on columns containing text. There are some great [examples](https://pola-rs.github.io/polars-book/user-guide/expressions/strings/) in the user guide. The [api documentation](https://pola-rs.github.io/polars/py-polars/html/reference/series/string.html) is also a good place to search for string functionality.


```python
is_snowing = weather_2012['Weather'].str.contains('Snow')
# Not super useful
is_snowing.head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (10,)</small><table border="1" class="dataframe"><thead><tr><th>Weather</th></tr><tr><td>bool</td></tr></thead><tbody><tr><td>false</td></tr><tr><td>false</td></tr><tr><td>false</td></tr><tr><td>false</td></tr><tr><td>false</td></tr><tr><td>false</td></tr><tr><td>false</td></tr><tr><td>false</td></tr><tr><td>false</td></tr><tr><td>false</td></tr></tbody></table></div>



This gives us a binary vector, which is a bit hard to look at, so we'll plot it.


```python
# More useful!
is_snowing=is_snowing.cast(pl.Int8)
sbn.lineplot(is_snowing)
```




    <Axes: >




    
![png](Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_files/Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_7_1.png)
    


# 6.2 Use resampling to find the snowiest month

If we wanted the median temperature each month, we could use the `groupby_dynamic()` method like this:


```python
# group_by_dynamic function requires the key to be pre-sorted
if not weather_2012['Date/Time'].is_sorted():
    weather_2012 = weather_2012.sort('Date/Time')
weather_2012 = weather_2012.set_sorted('Date/Time')

temp_by_month = weather_2012.group_by_dynamic(
    'Date/Time',
    every='1mo'
).agg(pl.col('Temp (C)').median())
plt.xticks(rotation=45)
display(temp_by_month)
sbn.barplot(temp_by_month, x='Date/Time', y='Temp (C)')
```


<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (12, 2)</small><table border="1" class="dataframe"><thead><tr><th>Date/Time</th><th>Temp (C)</th></tr><tr><td>datetime[μs]</td><td>f64</td></tr></thead><tbody><tr><td>2012-01-01 00:00:00</td><td>-7.05</td></tr><tr><td>2012-02-01 00:00:00</td><td>-4.1</td></tr><tr><td>2012-03-01 00:00:00</td><td>2.6</td></tr><tr><td>2012-04-01 00:00:00</td><td>6.3</td></tr><tr><td>2012-05-01 00:00:00</td><td>16.05</td></tr><tr><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2012-08-01 00:00:00</td><td>22.2</td></tr><tr><td>2012-09-01 00:00:00</td><td>16.1</td></tr><tr><td>2012-10-01 00:00:00</td><td>11.3</td></tr><tr><td>2012-11-01 00:00:00</td><td>1.05</td></tr><tr><td>2012-12-01 00:00:00</td><td>-2.85</td></tr></tbody></table></div>





    <Axes: xlabel='Date/Time', ylabel='Temp (C)'>




    
![png](Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_files/Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_10_2.png)
    


Unsurprisingly, July and August are the warmest.

So we can think of snowiness as being a bunch of 1s and 0s instead of `True`s and `False`s:


```python
is_snowing.cast(pl.Int8).head(10)
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (10,)</small><table border="1" class="dataframe"><thead><tr><th>Weather</th></tr><tr><td>i8</td></tr></thead><tbody><tr><td>0</td></tr><tr><td>0</td></tr><tr><td>0</td></tr><tr><td>0</td></tr><tr><td>0</td></tr><tr><td>0</td></tr><tr><td>0</td></tr><tr><td>0</td></tr><tr><td>0</td></tr><tr><td>0</td></tr></tbody></table></div>



and then use `groupby_dynamic` to find the percentage of time it was snowing each month


```python
snow_by_month = weather_2012.group_by_dynamic(
    'Date/Time',
    every='1mo'
).agg(
    is_snowing=pl.col('Weather').str.contains('Snow').cast(pl.Int8).mean()
)
snow_by_month
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (12, 2)</small><table border="1" class="dataframe"><thead><tr><th>Date/Time</th><th>is_snowing</th></tr><tr><td>datetime[μs]</td><td>f64</td></tr></thead><tbody><tr><td>2012-01-01 00:00:00</td><td>0.240591</td></tr><tr><td>2012-02-01 00:00:00</td><td>0.162356</td></tr><tr><td>2012-03-01 00:00:00</td><td>0.087366</td></tr><tr><td>2012-04-01 00:00:00</td><td>0.015278</td></tr><tr><td>2012-05-01 00:00:00</td><td>0.0</td></tr><tr><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2012-08-01 00:00:00</td><td>0.0</td></tr><tr><td>2012-09-01 00:00:00</td><td>0.0</td></tr><tr><td>2012-10-01 00:00:00</td><td>0.0</td></tr><tr><td>2012-11-01 00:00:00</td><td>0.038889</td></tr><tr><td>2012-12-01 00:00:00</td><td>0.251344</td></tr></tbody></table></div>




```python
plt.xticks(rotation=45)
sbn.barplot(snow_by_month, x='Date/Time', y='is_snowing')
```




    <Axes: xlabel='Date/Time', ylabel='is_snowing'>




    
![png](Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_files/Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_16_1.png)
    


So now we know! In 2012, December was the snowiest month. Also, this graph suggests something that I feel -- it starts snowing pretty abruptly in November, and then tapers off slowly and takes a long time to stop, with the last snow usually being in April or May.

# 6.3 Plotting temperature and snowiness stats together

We can also combine these two statistics (temperature, and snowiness) into one dataframe and plot them together:


```python
by_month = (
    weather_2012
    .group_by_dynamic(
        pl.col('Date/Time').alias('Date'),
        every='1mo')
    .agg(
        pl.col('Temp (C)').median(),
        pl.col('Weather').str.contains('Snow').cast(pl.Int8).mean().alias('is_snowing'))
    .sort('Date')
)
display(by_month)
```


<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (12, 3)</small><table border="1" class="dataframe"><thead><tr><th>Date</th><th>Temp (C)</th><th>is_snowing</th></tr><tr><td>datetime[μs]</td><td>f64</td><td>f64</td></tr></thead><tbody><tr><td>2012-01-01 00:00:00</td><td>-7.05</td><td>0.240591</td></tr><tr><td>2012-02-01 00:00:00</td><td>-4.1</td><td>0.162356</td></tr><tr><td>2012-03-01 00:00:00</td><td>2.6</td><td>0.087366</td></tr><tr><td>2012-04-01 00:00:00</td><td>6.3</td><td>0.015278</td></tr><tr><td>2012-05-01 00:00:00</td><td>16.05</td><td>0.0</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2012-08-01 00:00:00</td><td>22.2</td><td>0.0</td></tr><tr><td>2012-09-01 00:00:00</td><td>16.1</td><td>0.0</td></tr><tr><td>2012-10-01 00:00:00</td><td>11.3</td><td>0.0</td></tr><tr><td>2012-11-01 00:00:00</td><td>1.05</td><td>0.038889</td></tr><tr><td>2012-12-01 00:00:00</td><td>-2.85</td><td>0.251344</td></tr></tbody></table></div>



```python
fig, ax = plt.subplots(2, sharex=True)
sbn.barplot(by_month, x='Date', y='Temp (C)', ax=ax[0])
sbn.barplot(by_month, x='Date', y='is_snowing', ax=ax[1])
```




    <Axes: xlabel='Date', ylabel='is_snowing'>




    
![png](Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_files/Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_21_1.png)
    



```python
sbn.lineplot(by_month, x='Temp (C)', y='is_snowing')
```




    <Axes: xlabel='Temp (C)', ylabel='is_snowing'>




    
![png](Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_files/Chapter%206%20-%20String%20Operations-%20Which%20month%20was%20the%20snowiest_22_1.png)
    

