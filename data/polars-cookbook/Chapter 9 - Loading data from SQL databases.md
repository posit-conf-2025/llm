```python
import polars as pl
from pathlib import Path
import sqlite3

print(pl.__version__)
```

    1.6.0


# 9.1 Reading data from SQL databases

So far we've only talked about reading data from CSV files. That's a pretty common way to store data, but there are many others! Polars has a number of I/O methods at its disposal (see the [documentation](https://pola-rs.github.io/polars/py-polars/html/reference/io.html) for a full list of options). In this chapter we'll talk about reading data from SQL databases.

You can read data from a SQL database using the `pl.read_database` function. `read_database` will automatically convert SQL column names to DataFrame column names.

`read_database` takes 2 arguments: a query statement and a connection URI. This is great because it means you can read from *any* kind of SQL database -- it doesn't matter if it's MySQL, SQLite, PostgreSQL, or something else.

This example reads from a SQLite database, but any other database would work the same way.


```python
read_db_path = Path('../data/weather_2012.sqlite').absolute()
read_uri = f"sqlite:////{read_db_path}"
df = pl.read_database_uri("SELECT * from weather_2012 LIMIT 3", read_uri)
df
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 3)</small><table border="1" class="dataframe"><thead><tr><th>id</th><th>date_time</th><th>temp</th></tr><tr><td>i64</td><td>datetime[ns]</td><td>f64</td></tr></thead><tbody><tr><td>1</td><td>2012-01-01 00:00:00</td><td>-1.8</td></tr><tr><td>2</td><td>2012-01-01 01:00:00</td><td>-1.8</td></tr><tr><td>3</td><td>2012-01-01 02:00:00</td><td>-1.8</td></tr></tbody></table></div>



# 9.2 Writing to a SQLite database

Polars has a `write_database` function which creates a database table from a dataframe. Let's use it to move our 2012 weather data into SQL.


```python
weather_df = pl.read_csv('../data/weather_2012.csv')
write_db_path = Path('../data/test_db.sqlite').absolute()
write_uri = f"sqlite:////{write_db_path}"

con = sqlite3.connect(write_db_path)
con.execute("DROP TABLE IF EXISTS weather_2012")

weather_df.write_database("weather_2012", write_uri)
```




    8784



We can now read from the `weather_2012` table in  `test_db.sqlite`, and we see that we get the same data back:


```python
df = pl.read_database_uri("SELECT * from weather_2012 LIMIT 3", write_uri)
df
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 8)</small><table border="1" class="dataframe"><thead><tr><th>Date/Time</th><th>Temp (C)</th><th>Dew Point Temp (C)</th><th>Rel Hum (%)</th><th>Wind Spd (km/h)</th><th>Visibility (km)</th><th>Stn Press (kPa)</th><th>Weather</th></tr><tr><td>str</td><td>f64</td><td>f64</td><td>i64</td><td>i64</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>&quot;2012-01-01 00:00:00&quot;</td><td>-1.8</td><td>-3.9</td><td>86</td><td>4</td><td>8.0</td><td>101.24</td><td>&quot;Fog&quot;</td></tr><tr><td>&quot;2012-01-01 01:00:00&quot;</td><td>-1.8</td><td>-3.7</td><td>87</td><td>4</td><td>8.0</td><td>101.24</td><td>&quot;Fog&quot;</td></tr><tr><td>&quot;2012-01-01 02:00:00&quot;</td><td>-1.8</td><td>-3.4</td><td>89</td><td>7</td><td>4.0</td><td>101.26</td><td>&quot;Freezing Drizzle,Fog&quot;</td></tr></tbody></table></div>



The nice thing about having your data in a database is that you can do arbitrary SQL queries. This is cool especially if you're more familiar with SQL. Here's an example of sorting by the Weather column:


```python
df = pl.read_database_uri("SELECT * from weather_2012 ORDER BY Weather LIMIT 3", write_uri)
df
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 8)</small><table border="1" class="dataframe"><thead><tr><th>Date/Time</th><th>Temp (C)</th><th>Dew Point Temp (C)</th><th>Rel Hum (%)</th><th>Wind Spd (km/h)</th><th>Visibility (km)</th><th>Stn Press (kPa)</th><th>Weather</th></tr><tr><td>str</td><td>f64</td><td>f64</td><td>i64</td><td>i64</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>&quot;2012-01-03 19:00:00&quot;</td><td>-16.9</td><td>-24.8</td><td>50</td><td>24</td><td>25.0</td><td>101.74</td><td>&quot;Clear&quot;</td></tr><tr><td>&quot;2012-01-05 18:00:00&quot;</td><td>-7.1</td><td>-14.4</td><td>56</td><td>11</td><td>25.0</td><td>100.71</td><td>&quot;Clear&quot;</td></tr><tr><td>&quot;2012-01-05 19:00:00&quot;</td><td>-9.2</td><td>-15.4</td><td>61</td><td>7</td><td>25.0</td><td>100.8</td><td>&quot;Clear&quot;</td></tr></tbody></table></div>



If you have a PostgreSQL database or MySQL database, reading from it works exactly the same way as reading from a SQLite database.

# 9.3 Connecting to other kinds of database

To connect to a MySQL database:

*Note: For these to work, you will need a working MySQL / PostgreSQL database, with the correct localhost, database name, etc.*
pl.read_database_uri("select * from MY_TABLE", "mysql://username:password@server:port/database")
To connect to a PostgreSQL database:
pl.read_database_uri("select * from MY_TABLE", "postgresql://username:password@server:port/database")
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
    
    .warning{
        color: rgb( 240, 20, 20 )
        }  
