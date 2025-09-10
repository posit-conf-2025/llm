```python
import polars as pl
import polars.selectors as cs
print(pl.__version__)
```

    1.6.0


One of the main problems with messy data is: how do you know if it's messy or not?

We're going to use the NYC 311 service request dataset again here, since it's big and a bit unwieldy. If we try to read it in polars, we immediately run into an error. Polars cannot infer the data type of the data in the csv file:


```python
requests = pl.read_csv('../data/311-service-requests.csv')
```


    ---------------------------------------------------------------------------

    ComputeError                              Traceback (most recent call last)

    Cell In[2], line 1
    ----> 1 requests = pl.read_csv('../data/311-service-requests.csv')


    File ~/miniconda3/envs/pcb/lib/python3.12/site-packages/polars/_utils/deprecation.py:91, in deprecate_renamed_parameter.<locals>.decorate.<locals>.wrapper(*args, **kwargs)
         86 @wraps(function)
         87 def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
         88     _rename_keyword_argument(
         89         old_name, new_name, kwargs, function.__qualname__, version
         90     )
    ---> 91     return function(*args, **kwargs)


    File ~/miniconda3/envs/pcb/lib/python3.12/site-packages/polars/_utils/deprecation.py:91, in deprecate_renamed_parameter.<locals>.decorate.<locals>.wrapper(*args, **kwargs)
         86 @wraps(function)
         87 def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
         88     _rename_keyword_argument(
         89         old_name, new_name, kwargs, function.__qualname__, version
         90     )
    ---> 91     return function(*args, **kwargs)


    File ~/miniconda3/envs/pcb/lib/python3.12/site-packages/polars/_utils/deprecation.py:91, in deprecate_renamed_parameter.<locals>.decorate.<locals>.wrapper(*args, **kwargs)
         86 @wraps(function)
         87 def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
         88     _rename_keyword_argument(
         89         old_name, new_name, kwargs, function.__qualname__, version
         90     )
    ---> 91     return function(*args, **kwargs)


    File ~/miniconda3/envs/pcb/lib/python3.12/site-packages/polars/io/csv/functions.py:496, in read_csv(source, has_header, columns, new_columns, separator, comment_prefix, quote_char, skip_rows, schema, schema_overrides, null_values, missing_utf8_is_empty_string, ignore_errors, try_parse_dates, n_threads, infer_schema, infer_schema_length, batch_size, n_rows, encoding, low_memory, rechunk, use_pyarrow, storage_options, skip_rows_after_header, row_index_name, row_index_offset, sample_size, eol_char, raise_if_empty, truncate_ragged_lines, decimal_comma, glob)
        488 else:
        489     with prepare_file_arg(
        490         source,
        491         encoding=encoding,
       (...)
        494         storage_options=storage_options,
        495     ) as data:
    --> 496         df = _read_csv_impl(
        497             data,
        498             has_header=has_header,
        499             columns=columns if columns else projection,
        500             separator=separator,
        501             comment_prefix=comment_prefix,
        502             quote_char=quote_char,
        503             skip_rows=skip_rows,
        504             schema_overrides=schema_overrides,
        505             schema=schema,
        506             null_values=null_values,
        507             missing_utf8_is_empty_string=missing_utf8_is_empty_string,
        508             ignore_errors=ignore_errors,
        509             try_parse_dates=try_parse_dates,
        510             n_threads=n_threads,
        511             infer_schema_length=infer_schema_length,
        512             batch_size=batch_size,
        513             n_rows=n_rows,
        514             encoding=encoding if encoding == "utf8-lossy" else "utf8",
        515             low_memory=low_memory,
        516             rechunk=rechunk,
        517             skip_rows_after_header=skip_rows_after_header,
        518             row_index_name=row_index_name,
        519             row_index_offset=row_index_offset,
        520             sample_size=sample_size,
        521             eol_char=eol_char,
        522             raise_if_empty=raise_if_empty,
        523             truncate_ragged_lines=truncate_ragged_lines,
        524             decimal_comma=decimal_comma,
        525             glob=glob,
        526         )
        528 if new_columns:
        529     return _update_columns(df, new_columns)


    File ~/miniconda3/envs/pcb/lib/python3.12/site-packages/polars/io/csv/functions.py:642, in _read_csv_impl(source, has_header, columns, separator, comment_prefix, quote_char, skip_rows, schema, schema_overrides, null_values, missing_utf8_is_empty_string, ignore_errors, try_parse_dates, n_threads, infer_schema_length, batch_size, n_rows, encoding, low_memory, rechunk, skip_rows_after_header, row_index_name, row_index_offset, sample_size, eol_char, raise_if_empty, truncate_ragged_lines, decimal_comma, glob)
        638         raise ValueError(msg)
        640 projection, columns = parse_columns_arg(columns)
    --> 642 pydf = PyDataFrame.read_csv(
        643     source,
        644     infer_schema_length,
        645     batch_size,
        646     has_header,
        647     ignore_errors,
        648     n_rows,
        649     skip_rows,
        650     projection,
        651     separator,
        652     rechunk,
        653     columns,
        654     encoding,
        655     n_threads,
        656     path,
        657     dtype_list,
        658     dtype_slice,
        659     low_memory,
        660     comment_prefix,
        661     quote_char,
        662     processed_null_values,
        663     missing_utf8_is_empty_string,
        664     try_parse_dates,
        665     skip_rows_after_header,
        666     parse_row_index_args(row_index_name, row_index_offset),
        667     sample_size=sample_size,
        668     eol_char=eol_char,
        669     raise_if_empty=raise_if_empty,
        670     truncate_ragged_lines=truncate_ragged_lines,
        671     decimal_comma=decimal_comma,
        672     schema=schema,
        673 )
        674 return wrap_df(pydf)


    ComputeError: could not parse `11549-3650` as dtype `i64` at column 'Incident Zip' (column number 9)
    
    The current offset in the file is 34985879 bytes.
    
    You might want to try:
    - increasing `infer_schema_length` (e.g. `infer_schema_length=10000`),
    - specifying correct dtype with the `dtypes` argument
    - setting `ignore_errors` to `True`,
    - adding `11549-3650` to the `null_values` list.
    
    Original error: ```remaining bytes non-empty```


We can force polars to try harder to infer the data type by setting `infer_schema_length` to `None`. Looking at the schema below, I can see that `Incident Zip` was parsed as a `string`. That doesn't look right.


```python
requests = pl.read_csv('../data/311-service-requests.csv', infer_schema_length=None)
display(requests.head())
display(requests.schema)
```


<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 52)</small><table border="1" class="dataframe"><thead><tr><th>Unique Key</th><th>Created Date</th><th>Closed Date</th><th>Agency</th><th>Agency Name</th><th>Complaint Type</th><th>Descriptor</th><th>Location Type</th><th>Incident Zip</th><th>Incident Address</th><th>Street Name</th><th>Cross Street 1</th><th>Cross Street 2</th><th>Intersection Street 1</th><th>Intersection Street 2</th><th>Address Type</th><th>City</th><th>Landmark</th><th>Facility Type</th><th>Status</th><th>Due Date</th><th>Resolution Action Updated Date</th><th>Community Board</th><th>Borough</th><th>X Coordinate (State Plane)</th><th>Y Coordinate (State Plane)</th><th>Park Facility Name</th><th>Park Borough</th><th>School Name</th><th>School Number</th><th>School Region</th><th>School Code</th><th>School Phone Number</th><th>School Address</th><th>School City</th><th>School State</th><th>School Zip</th><th>School Not Found</th><th>School or Citywide Complaint</th><th>Vehicle Type</th><th>Taxi Company Borough</th><th>Taxi Pick Up Location</th><th>Bridge Highway Name</th><th>Bridge Highway Direction</th><th>Road Ramp</th><th>Bridge Highway Segment</th><th>Garage Lot Name</th><th>Ferry Direction</th><th>Ferry Terminal Name</th><th>Latitude</th><th>Longitude</th><th>Location</th></tr><tr><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>i64</td><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>26589651</td><td>&quot;10/31/2013 02:08:41 AM&quot;</td><td>null</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Talking&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11432&quot;</td><td>&quot;90-03 169 STREET&quot;</td><td>&quot;169 STREET&quot;</td><td>&quot;90 AVENUE&quot;</td><td>&quot;91 AVENUE&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;JAMAICA&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Assigned&quot;</td><td>&quot;10/31/2013 10:08:41 AM&quot;</td><td>&quot;10/31/2013 02:35:17 AM&quot;</td><td>&quot;12 QUEENS&quot;</td><td>&quot;QUEENS&quot;</td><td>1042027</td><td>197389</td><td>&quot;Unspecified&quot;</td><td>&quot;QUEENS&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.708275</td><td>-73.791604</td><td>&quot;(40.70827532593202, -73.791603…</td></tr><tr><td>26593698</td><td>&quot;10/31/2013 02:01:04 AM&quot;</td><td>null</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Illegal Parking&quot;</td><td>&quot;Commercial Overnight Parking&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11378&quot;</td><td>&quot;58 AVENUE&quot;</td><td>&quot;58 AVENUE&quot;</td><td>&quot;58 PLACE&quot;</td><td>&quot;59 STREET&quot;</td><td>null</td><td>null</td><td>&quot;BLOCKFACE&quot;</td><td>&quot;MASPETH&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Open&quot;</td><td>&quot;10/31/2013 10:01:04 AM&quot;</td><td>null</td><td>&quot;05 QUEENS&quot;</td><td>&quot;QUEENS&quot;</td><td>1009349</td><td>201984</td><td>&quot;Unspecified&quot;</td><td>&quot;QUEENS&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.721041</td><td>-73.909453</td><td>&quot;(40.721040535628305, -73.90945…</td></tr><tr><td>26594139</td><td>&quot;10/31/2013 02:00:24 AM&quot;</td><td>&quot;10/31/2013 02:40:32 AM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Commercial&quot;</td><td>&quot;Loud Music/Party&quot;</td><td>&quot;Club/Bar/Restaurant&quot;</td><td>&quot;10032&quot;</td><td>&quot;4060 BROADWAY&quot;</td><td>&quot;BROADWAY&quot;</td><td>&quot;WEST 171 STREET&quot;</td><td>&quot;WEST 172 STREET&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;NEW YORK&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 10:00:24 AM&quot;</td><td>&quot;10/31/2013 02:39:42 AM&quot;</td><td>&quot;12 MANHATTAN&quot;</td><td>&quot;MANHATTAN&quot;</td><td>1001088</td><td>246531</td><td>&quot;Unspecified&quot;</td><td>&quot;MANHATTAN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.84333</td><td>-73.939144</td><td>&quot;(40.84332975466513, -73.939143…</td></tr><tr><td>26595721</td><td>&quot;10/31/2013 01:56:23 AM&quot;</td><td>&quot;10/31/2013 02:21:48 AM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Vehicle&quot;</td><td>&quot;Car/Truck Horn&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;10023&quot;</td><td>&quot;WEST 72 STREET&quot;</td><td>&quot;WEST 72 STREET&quot;</td><td>&quot;COLUMBUS AVENUE&quot;</td><td>&quot;AMSTERDAM AVENUE&quot;</td><td>null</td><td>null</td><td>&quot;BLOCKFACE&quot;</td><td>&quot;NEW YORK&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 09:56:23 AM&quot;</td><td>&quot;10/31/2013 02:21:10 AM&quot;</td><td>&quot;07 MANHATTAN&quot;</td><td>&quot;MANHATTAN&quot;</td><td>989730</td><td>222727</td><td>&quot;Unspecified&quot;</td><td>&quot;MANHATTAN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.778009</td><td>-73.980213</td><td>&quot;(40.7780087446372, -73.9802134…</td></tr><tr><td>26590930</td><td>&quot;10/31/2013 01:53:44 AM&quot;</td><td>null</td><td>&quot;DOHMH&quot;</td><td>&quot;Department of Health and Menta…</td><td>&quot;Rodent&quot;</td><td>&quot;Condition Attracting Rodents&quot;</td><td>&quot;Vacant Lot&quot;</td><td>&quot;10027&quot;</td><td>&quot;WEST 124 STREET&quot;</td><td>&quot;WEST 124 STREET&quot;</td><td>&quot;LENOX AVENUE&quot;</td><td>&quot;ADAM CLAYTON POWELL JR BOULEVA…</td><td>null</td><td>null</td><td>&quot;BLOCKFACE&quot;</td><td>&quot;NEW YORK&quot;</td><td>null</td><td>&quot;N/A&quot;</td><td>&quot;Pending&quot;</td><td>&quot;11/30/2013 01:53:44 AM&quot;</td><td>&quot;10/31/2013 01:59:54 AM&quot;</td><td>&quot;10 MANHATTAN&quot;</td><td>&quot;MANHATTAN&quot;</td><td>998815</td><td>233545</td><td>&quot;Unspecified&quot;</td><td>&quot;MANHATTAN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.807691</td><td>-73.947387</td><td>&quot;(40.80769092704951, -73.947387…</td></tr></tbody></table></div>



    Schema([('Unique Key', Int64),
            ('Created Date', String),
            ('Closed Date', String),
            ('Agency', String),
            ('Agency Name', String),
            ('Complaint Type', String),
            ('Descriptor', String),
            ('Location Type', String),
            ('Incident Zip', String),
            ('Incident Address', String),
            ('Street Name', String),
            ('Cross Street 1', String),
            ('Cross Street 2', String),
            ('Intersection Street 1', String),
            ('Intersection Street 2', String),
            ('Address Type', String),
            ('City', String),
            ('Landmark', String),
            ('Facility Type', String),
            ('Status', String),
            ('Due Date', String),
            ('Resolution Action Updated Date', String),
            ('Community Board', String),
            ('Borough', String),
            ('X Coordinate (State Plane)', Int64),
            ('Y Coordinate (State Plane)', Int64),
            ('Park Facility Name', String),
            ('Park Borough', String),
            ('School Name', String),
            ('School Number', String),
            ('School Region', String),
            ('School Code', String),
            ('School Phone Number', String),
            ('School Address', String),
            ('School City', String),
            ('School State', String),
            ('School Zip', String),
            ('School Not Found', String),
            ('School or Citywide Complaint', String),
            ('Vehicle Type', String),
            ('Taxi Company Borough', String),
            ('Taxi Pick Up Location', String),
            ('Bridge Highway Name', String),
            ('Bridge Highway Direction', String),
            ('Road Ramp', String),
            ('Bridge Highway Segment', String),
            ('Garage Lot Name', String),
            ('Ferry Direction', String),
            ('Ferry Terminal Name', String),
            ('Latitude', Float64),
            ('Longitude', Float64),
            ('Location', String)])


# 7.1 How do we know if it's messy? 

We're going to look at a few columns here. I know already that there are some problems with the zip code, so let's look at that first.
 
To get a sense for whether a column has problems, I usually use `.unique()` to look at all its values. If it's a numeric column, I'll instead plot a histogram to get a sense of the distribution.

When we look at the unique values in "Incident Zip", it quickly becomes clear that this is a mess.

Some of the problems:

* Some have been parsed as strings, and some as floats
* There are `nan`s 
* Some of the zip codes are `29616-0759` or `83`
* There are some N/A values that polars didn't recognize, like 'N/A' and 'NO CLUE'

What we can do:

* Normalize 'N/A' and 'NO CLUE' into regular nan values
* Look at what's up with the 83, and decide what to do
* Make everything strings


```python
requests['Incident Zip'].unique().sort()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (251,)</small><table border="1" class="dataframe"><thead><tr><th>Incident Zip</th></tr><tr><td>str</td></tr></thead><tbody><tr><td>null</td></tr><tr><td>&quot;00000&quot;</td></tr><tr><td>&quot;000000&quot;</td></tr><tr><td>&quot;00083&quot;</td></tr><tr><td>&quot;02061&quot;</td></tr><tr><td>&hellip;</td></tr><tr><td>&quot;90010&quot;</td></tr><tr><td>&quot;92123&quot;</td></tr><tr><td>&quot;N/A&quot;</td></tr><tr><td>&quot;NA&quot;</td></tr><tr><td>&quot;NO CLUE&quot;</td></tr></tbody></table></div>



# 7.2 Fixing the null_values and string/float confusion

We can pass a `null_values` option to `pl.read_csv` to clean this up a little bit. We can also specify that the type of Incident Zip is a string, not a float.


```python
null_values = ['NO CLUE', 'N/A', '0', 'NA']
requests = pl.read_csv('../data/311-service-requests.csv', null_values=null_values, dtypes={'Incident Zip':pl.String})
requests['Incident Zip'].unique().sort()
```

    /var/folders/sz/c22f1dwn4pz41534xrybbydc0000gn/T/ipykernel_26170/480128266.py:2: DeprecationWarning: The argument `dtypes` for `read_csv` is deprecated. It has been renamed to `schema_overrides`.
      requests = pl.read_csv('../data/311-service-requests.csv', null_values=null_values, dtypes={'Incident Zip':pl.String})





<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (248,)</small><table border="1" class="dataframe"><thead><tr><th>Incident Zip</th></tr><tr><td>str</td></tr></thead><tbody><tr><td>null</td></tr><tr><td>&quot;00000&quot;</td></tr><tr><td>&quot;000000&quot;</td></tr><tr><td>&quot;00083&quot;</td></tr><tr><td>&quot;02061&quot;</td></tr><tr><td>&hellip;</td></tr><tr><td>&quot;70711&quot;</td></tr><tr><td>&quot;77056&quot;</td></tr><tr><td>&quot;77092-2016&quot;</td></tr><tr><td>&quot;90010&quot;</td></tr><tr><td>&quot;92123&quot;</td></tr></tbody></table></div>



# 7.3 What's up with the dashes?


```python
rows_with_dashes = requests.filter(
    pl.col('Incident Zip').str.contains('-')
)
print('number of zip codes with dashes: ', rows_with_dashes.height)
rows_with_dashes.head()
```

    number of zip codes with dashes:  5





<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 52)</small><table border="1" class="dataframe"><thead><tr><th>Unique Key</th><th>Created Date</th><th>Closed Date</th><th>Agency</th><th>Agency Name</th><th>Complaint Type</th><th>Descriptor</th><th>Location Type</th><th>Incident Zip</th><th>Incident Address</th><th>Street Name</th><th>Cross Street 1</th><th>Cross Street 2</th><th>Intersection Street 1</th><th>Intersection Street 2</th><th>Address Type</th><th>City</th><th>Landmark</th><th>Facility Type</th><th>Status</th><th>Due Date</th><th>Resolution Action Updated Date</th><th>Community Board</th><th>Borough</th><th>X Coordinate (State Plane)</th><th>Y Coordinate (State Plane)</th><th>Park Facility Name</th><th>Park Borough</th><th>School Name</th><th>School Number</th><th>School Region</th><th>School Code</th><th>School Phone Number</th><th>School Address</th><th>School City</th><th>School State</th><th>School Zip</th><th>School Not Found</th><th>School or Citywide Complaint</th><th>Vehicle Type</th><th>Taxi Company Borough</th><th>Taxi Pick Up Location</th><th>Bridge Highway Name</th><th>Bridge Highway Direction</th><th>Road Ramp</th><th>Bridge Highway Segment</th><th>Garage Lot Name</th><th>Ferry Direction</th><th>Ferry Terminal Name</th><th>Latitude</th><th>Longitude</th><th>Location</th></tr><tr><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>i64</td><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>26550551</td><td>&quot;10/24/2013 06:16:34 PM&quot;</td><td>null</td><td>&quot;DCA&quot;</td><td>&quot;Department of Consumer Affairs&quot;</td><td>&quot;Consumer Complaint&quot;</td><td>&quot;False Advertising&quot;</td><td>null</td><td>&quot;77092-2016&quot;</td><td>&quot;2700 EAST SELTICE WAY&quot;</td><td>&quot;EAST SELTICE WAY&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;HOUSTON&quot;</td><td>null</td><td>null</td><td>&quot;Assigned&quot;</td><td>&quot;11/13/2013 11:15:20 AM&quot;</td><td>&quot;10/29/2013 11:16:16 AM&quot;</td><td>&quot;0 Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>null</td><td>null</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td></tr><tr><td>26548831</td><td>&quot;10/24/2013 09:35:10 AM&quot;</td><td>null</td><td>&quot;DCA&quot;</td><td>&quot;Department of Consumer Affairs&quot;</td><td>&quot;Consumer Complaint&quot;</td><td>&quot;Harassment&quot;</td><td>null</td><td>&quot;55164-0737&quot;</td><td>&quot;P.O. BOX 64437&quot;</td><td>&quot;64437&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;ST. PAUL&quot;</td><td>null</td><td>null</td><td>&quot;Assigned&quot;</td><td>&quot;11/13/2013 02:30:21 PM&quot;</td><td>&quot;10/29/2013 02:31:06 PM&quot;</td><td>&quot;0 Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>null</td><td>null</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td></tr><tr><td>26488417</td><td>&quot;10/15/2013 03:40:33 PM&quot;</td><td>null</td><td>&quot;TLC&quot;</td><td>&quot;Taxi and Limousine Commission&quot;</td><td>&quot;Taxi Complaint&quot;</td><td>&quot;Driver Complaint&quot;</td><td>&quot;Street&quot;</td><td>&quot;11549-3650&quot;</td><td>&quot;365 HOFSTRA UNIVERSITY&quot;</td><td>&quot;HOFSTRA UNIVERSITY&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;HEMSTEAD&quot;</td><td>null</td><td>null</td><td>&quot;Assigned&quot;</td><td>&quot;11/30/2013 01:20:33 PM&quot;</td><td>&quot;10/16/2013 01:21:39 PM&quot;</td><td>&quot;0 Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>null</td><td>null</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>&quot;La Guardia Airport&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td></tr><tr><td>26468296</td><td>&quot;10/10/2013 12:36:43 PM&quot;</td><td>&quot;10/26/2013 01:07:07 AM&quot;</td><td>&quot;DCA&quot;</td><td>&quot;Department of Consumer Affairs&quot;</td><td>&quot;Consumer Complaint&quot;</td><td>&quot;Debt Not Owed&quot;</td><td>null</td><td>&quot;29616-0759&quot;</td><td>&quot;PO BOX 25759&quot;</td><td>&quot;BOX 25759&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;GREENVILLE&quot;</td><td>null</td><td>null</td><td>&quot;Closed&quot;</td><td>&quot;10/26/2013 09:20:28 AM&quot;</td><td>&quot;10/26/2013 01:07:07 AM&quot;</td><td>&quot;0 Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>null</td><td>null</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td></tr><tr><td>26461137</td><td>&quot;10/09/2013 05:23:46 PM&quot;</td><td>&quot;10/25/2013 01:06:41 AM&quot;</td><td>&quot;DCA&quot;</td><td>&quot;Department of Consumer Affairs&quot;</td><td>&quot;Consumer Complaint&quot;</td><td>&quot;Harassment&quot;</td><td>null</td><td>&quot;35209-3114&quot;</td><td>&quot;600 BEACON PKWY&quot;</td><td>&quot;BEACON PKWY&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;BIRMINGHAM&quot;</td><td>null</td><td>null</td><td>&quot;Closed&quot;</td><td>&quot;10/25/2013 02:43:42 PM&quot;</td><td>&quot;10/25/2013 01:06:41 AM&quot;</td><td>&quot;0 Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>null</td><td>null</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td></tr></tbody></table></div>



I thought these were missing data and originally deleted them. But then my friend Dave pointed out that 9-digit zip codes are normal. Let's look at all the zip codes with more than 5 digits, make sure they're okay, and then truncate them.


```python
requests.filter(
    pl.col('Incident Zip').str.contains('-')
)['Incident Zip'].unique()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5,)</small><table border="1" class="dataframe"><thead><tr><th>Incident Zip</th></tr><tr><td>str</td></tr></thead><tbody><tr><td>&quot;77092-2016&quot;</td></tr><tr><td>&quot;11549-3650&quot;</td></tr><tr><td>&quot;55164-0737&quot;</td></tr><tr><td>&quot;35209-3114&quot;</td></tr><tr><td>&quot;29616-0759&quot;</td></tr></tbody></table></div>



Those all look okay to truncate to me.


```python
requests = requests.with_columns(
    pl.col('Incident Zip').str.slice(0, 5)
)
requests.filter(
    pl.col('Incident Zip').str.contains('-')
)['Incident Zip'].unique()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (0,)</small><table border="1" class="dataframe"><thead><tr><th>Incident Zip</th></tr><tr><td>str</td></tr></thead><tbody></tbody></table></div>



Done.

Earlier I thought 00083 was a broken zip code, but turns out Central Park's zip code 00083! Shows what I know. I'm still concerned about the 00000 zip codes, though: let's look at that. 


```python
requests.filter(
    pl.col('Incident Zip') == '00000'
)
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (2, 52)</small><table border="1" class="dataframe"><thead><tr><th>Unique Key</th><th>Created Date</th><th>Closed Date</th><th>Agency</th><th>Agency Name</th><th>Complaint Type</th><th>Descriptor</th><th>Location Type</th><th>Incident Zip</th><th>Incident Address</th><th>Street Name</th><th>Cross Street 1</th><th>Cross Street 2</th><th>Intersection Street 1</th><th>Intersection Street 2</th><th>Address Type</th><th>City</th><th>Landmark</th><th>Facility Type</th><th>Status</th><th>Due Date</th><th>Resolution Action Updated Date</th><th>Community Board</th><th>Borough</th><th>X Coordinate (State Plane)</th><th>Y Coordinate (State Plane)</th><th>Park Facility Name</th><th>Park Borough</th><th>School Name</th><th>School Number</th><th>School Region</th><th>School Code</th><th>School Phone Number</th><th>School Address</th><th>School City</th><th>School State</th><th>School Zip</th><th>School Not Found</th><th>School or Citywide Complaint</th><th>Vehicle Type</th><th>Taxi Company Borough</th><th>Taxi Pick Up Location</th><th>Bridge Highway Name</th><th>Bridge Highway Direction</th><th>Road Ramp</th><th>Bridge Highway Segment</th><th>Garage Lot Name</th><th>Ferry Direction</th><th>Ferry Terminal Name</th><th>Latitude</th><th>Longitude</th><th>Location</th></tr><tr><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>i64</td><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>26529313</td><td>&quot;10/22/2013 02:51:06 PM&quot;</td><td>null</td><td>&quot;TLC&quot;</td><td>&quot;Taxi and Limousine Commission&quot;</td><td>&quot;Taxi Complaint&quot;</td><td>&quot;Driver Complaint&quot;</td><td>null</td><td>&quot;00000&quot;</td><td>&quot;EWR EWR&quot;</td><td>&quot;EWR&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;NEWARK&quot;</td><td>null</td><td>null</td><td>&quot;Assigned&quot;</td><td>&quot;12/07/2013 09:53:51 AM&quot;</td><td>&quot;10/23/2013 09:54:43 AM&quot;</td><td>&quot;0 Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>null</td><td>null</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>&quot;Other&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td></tr><tr><td>26507389</td><td>&quot;10/17/2013 05:48:44 PM&quot;</td><td>null</td><td>&quot;TLC&quot;</td><td>&quot;Taxi and Limousine Commission&quot;</td><td>&quot;Taxi Complaint&quot;</td><td>&quot;Driver Complaint&quot;</td><td>&quot;Street&quot;</td><td>&quot;00000&quot;</td><td>&quot;1 NEWARK AIRPORT&quot;</td><td>&quot;NEWARK AIRPORT&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;NEWARK&quot;</td><td>null</td><td>null</td><td>&quot;Assigned&quot;</td><td>&quot;12/02/2013 11:59:46 AM&quot;</td><td>&quot;10/18/2013 12:01:08 PM&quot;</td><td>&quot;0 Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>null</td><td>null</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>&quot;Other&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td></tr></tbody></table></div>



This looks bad to me. Let's set these to nan.


```python
requests = requests.with_columns(
    pl.when(pl.col('Incident Zip') == '00000').then(None).otherwise(pl.col('Incident Zip')).alias('Incident Zip')
)
requests.filter(
    pl.col('Incident Zip') == '00000'
)
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (0, 52)</small><table border="1" class="dataframe"><thead><tr><th>Unique Key</th><th>Created Date</th><th>Closed Date</th><th>Agency</th><th>Agency Name</th><th>Complaint Type</th><th>Descriptor</th><th>Location Type</th><th>Incident Zip</th><th>Incident Address</th><th>Street Name</th><th>Cross Street 1</th><th>Cross Street 2</th><th>Intersection Street 1</th><th>Intersection Street 2</th><th>Address Type</th><th>City</th><th>Landmark</th><th>Facility Type</th><th>Status</th><th>Due Date</th><th>Resolution Action Updated Date</th><th>Community Board</th><th>Borough</th><th>X Coordinate (State Plane)</th><th>Y Coordinate (State Plane)</th><th>Park Facility Name</th><th>Park Borough</th><th>School Name</th><th>School Number</th><th>School Region</th><th>School Code</th><th>School Phone Number</th><th>School Address</th><th>School City</th><th>School State</th><th>School Zip</th><th>School Not Found</th><th>School or Citywide Complaint</th><th>Vehicle Type</th><th>Taxi Company Borough</th><th>Taxi Pick Up Location</th><th>Bridge Highway Name</th><th>Bridge Highway Direction</th><th>Road Ramp</th><th>Bridge Highway Segment</th><th>Garage Lot Name</th><th>Ferry Direction</th><th>Ferry Terminal Name</th><th>Latitude</th><th>Longitude</th><th>Location</th></tr><tr><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>i64</td><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody></tbody></table></div>



Great. Let's see where we are now:


```python
unique_zips = requests['Incident Zip'].unique().sort()
unique_zips
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (246,)</small><table border="1" class="dataframe"><thead><tr><th>Incident Zip</th></tr><tr><td>str</td></tr></thead><tbody><tr><td>null</td></tr><tr><td>&quot;00083&quot;</td></tr><tr><td>&quot;02061&quot;</td></tr><tr><td>&quot;06901&quot;</td></tr><tr><td>&quot;07020&quot;</td></tr><tr><td>&hellip;</td></tr><tr><td>&quot;70711&quot;</td></tr><tr><td>&quot;77056&quot;</td></tr><tr><td>&quot;77092&quot;</td></tr><tr><td>&quot;90010&quot;</td></tr><tr><td>&quot;92123&quot;</td></tr></tbody></table></div>



Amazing! This is much cleaner. There's something a bit weird here, though -- I looked up 77056 on Google maps, and that's in Texas.

Let's take a closer look:


```python
requests.lazy().select(
    'Incident Zip',
    'Descriptor',
    'City'
).filter(
    pl.col('Incident Zip') == "77056"
).sort('Incident Zip').collect()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (1, 3)</small><table border="1" class="dataframe"><thead><tr><th>Incident Zip</th><th>Descriptor</th><th>City</th></tr><tr><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>&quot;77056&quot;</td><td>&quot;Debt Not Owed&quot;</td><td>&quot;HOUSTON&quot;</td></tr></tbody></table></div>



Okay, there really are requests coming from Houston! Good to know. Filtering by zip code is probably a bad way to handle this -- we should really be looking at the city instead.


```python
requests['City'].str.to_uppercase().value_counts(sort=True)
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (101, 2)</small><table border="1" class="dataframe"><thead><tr><th>City</th><th>count</th></tr><tr><td>str</td><td>u32</td></tr></thead><tbody><tr><td>&quot;BROOKLYN&quot;</td><td>31662</td></tr><tr><td>&quot;NEW YORK&quot;</td><td>22664</td></tr><tr><td>&quot;BRONX&quot;</td><td>18438</td></tr><tr><td>null</td><td>12215</td></tr><tr><td>&quot;STATEN ISLAND&quot;</td><td>4766</td></tr><tr><td>&hellip;</td><td>&hellip;</td></tr><tr><td>&quot;SYRACUSE&quot;</td><td>1</td></tr><tr><td>&quot;NANUET&quot;</td><td>1</td></tr><tr><td>&quot;FARMINGDALE&quot;</td><td>1</td></tr><tr><td>&quot;NEW YOR&quot;</td><td>1</td></tr><tr><td>&quot;NEWARK AIRPORT&quot;</td><td>1</td></tr></tbody></table></div>



There are 12,215 `null` values in the `City` column. Upon closer look, it seems that many of these rows also have missing `Incident Zip` values as well:


```python
requests.select(
    'Incident Zip',
    'Descriptor',
    'City'
).filter(
    pl.col('City').is_null()
).sort('Incident Zip')
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (12_215, 3)</small><table border="1" class="dataframe"><thead><tr><th>Incident Zip</th><th>Descriptor</th><th>City</th></tr><tr><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>null</td><td>&quot;Street Light Out&quot;</td><td>null</td></tr><tr><td>null</td><td>&quot;Street Light Out&quot;</td><td>null</td></tr><tr><td>null</td><td>&quot;Medicaid&quot;</td><td>null</td></tr><tr><td>null</td><td>&quot;Controller&quot;</td><td>null</td></tr><tr><td>null</td><td>&quot;Property Tax Exemption Applica…</td><td>null</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>null</td><td>&quot;Street Light Out&quot;</td><td>null</td></tr><tr><td>null</td><td>&quot;Street Light Out&quot;</td><td>null</td></tr><tr><td>null</td><td>&quot;Property Tax Exemption Applica…</td><td>null</td></tr><tr><td>&quot;10022&quot;</td><td>&quot;Driver Complaint&quot;</td><td>null</td></tr><tr><td>&quot;11429&quot;</td><td>&quot;Dead Animal&quot;</td><td>null</td></tr></tbody></table></div>



# 7.4 Putting it together

Here's what we ended up doing to clean up our zip codes, all together:


```python
null_values = ['NO CLUE', 'N/A', '0', 'NA']
requests = (
    pl.scan_csv('../data/311-service-requests.csv', null_values=null_values, schema_overrides={'Incident Zip':pl.String})
    .with_columns(pl.col('Incident Zip').str.slice(0, 5))
)
requests = (
    requests
    .with_columns(pl.when(pl.col('Incident Zip') == '00000').then(None).otherwise(pl.col('Incident Zip')).alias('Incident Zip'))
    .filter(pl.col('Incident Zip').is_not_null())
    .collect()
)
```


```python
requests['Incident Zip'].unique().sort()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (245,)</small><table border="1" class="dataframe"><thead><tr><th>Incident Zip</th></tr><tr><td>str</td></tr></thead><tbody><tr><td>&quot;00083&quot;</td></tr><tr><td>&quot;02061&quot;</td></tr><tr><td>&quot;06901&quot;</td></tr><tr><td>&quot;07020&quot;</td></tr><tr><td>&quot;07087&quot;</td></tr><tr><td>&hellip;</td></tr><tr><td>&quot;70711&quot;</td></tr><tr><td>&quot;77056&quot;</td></tr><tr><td>&quot;77092&quot;</td></tr><tr><td>&quot;90010&quot;</td></tr><tr><td>&quot;92123&quot;</td></tr></tbody></table></div>



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
