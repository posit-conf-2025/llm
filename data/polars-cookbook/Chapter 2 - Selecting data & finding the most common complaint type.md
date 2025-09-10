```python
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


We're going to use a new dataset here, to demonstrate how to deal with larger datasets. This is a subset of the of 311 service requests from [NYC Open Data](https://nycopendata.socrata.com/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9). 


```python
# because of mixed types we specify dtype to prevent any errors
complaints = pl.read_csv('../data/311-service-requests.csv', schema_overrides={'Incident Zip':pl.String})
```

Notice that we had to explicitly specify the dtype of the 'Incident Zip' column as a string type. This means that it's encountered a problem reading in our data. In this case it almost certainly means that it has columns where some of the entries are strings and some are integers.

For now we're going to ignore it and hope we don't run into a problem, but in the long run we'd need to investigate this warning.

# 2.1 What's even in it? (the summary)

Use the head function to get the top rows of a dataframe This is a great way to get a sense for what kind of information is in the dataframe -- take a minute to look at the contents and get a feel for this dataset.


```python
complaints.head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 52)</small><table border="1" class="dataframe"><thead><tr><th>Unique Key</th><th>Created Date</th><th>Closed Date</th><th>Agency</th><th>Agency Name</th><th>Complaint Type</th><th>Descriptor</th><th>Location Type</th><th>Incident Zip</th><th>Incident Address</th><th>Street Name</th><th>Cross Street 1</th><th>Cross Street 2</th><th>Intersection Street 1</th><th>Intersection Street 2</th><th>Address Type</th><th>City</th><th>Landmark</th><th>Facility Type</th><th>Status</th><th>Due Date</th><th>Resolution Action Updated Date</th><th>Community Board</th><th>Borough</th><th>X Coordinate (State Plane)</th><th>Y Coordinate (State Plane)</th><th>Park Facility Name</th><th>Park Borough</th><th>School Name</th><th>School Number</th><th>School Region</th><th>School Code</th><th>School Phone Number</th><th>School Address</th><th>School City</th><th>School State</th><th>School Zip</th><th>School Not Found</th><th>School or Citywide Complaint</th><th>Vehicle Type</th><th>Taxi Company Borough</th><th>Taxi Pick Up Location</th><th>Bridge Highway Name</th><th>Bridge Highway Direction</th><th>Road Ramp</th><th>Bridge Highway Segment</th><th>Garage Lot Name</th><th>Ferry Direction</th><th>Ferry Terminal Name</th><th>Latitude</th><th>Longitude</th><th>Location</th></tr><tr><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>i64</td><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>26589651</td><td>&quot;10/31/2013 02:08:41 AM&quot;</td><td>null</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Talking&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11432&quot;</td><td>&quot;90-03 169 STREET&quot;</td><td>&quot;169 STREET&quot;</td><td>&quot;90 AVENUE&quot;</td><td>&quot;91 AVENUE&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;JAMAICA&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Assigned&quot;</td><td>&quot;10/31/2013 10:08:41 AM&quot;</td><td>&quot;10/31/2013 02:35:17 AM&quot;</td><td>&quot;12 QUEENS&quot;</td><td>&quot;QUEENS&quot;</td><td>1042027</td><td>197389</td><td>&quot;Unspecified&quot;</td><td>&quot;QUEENS&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.708275</td><td>-73.791604</td><td>&quot;(40.70827532593202, -73.791603…</td></tr><tr><td>26593698</td><td>&quot;10/31/2013 02:01:04 AM&quot;</td><td>null</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Illegal Parking&quot;</td><td>&quot;Commercial Overnight Parking&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11378&quot;</td><td>&quot;58 AVENUE&quot;</td><td>&quot;58 AVENUE&quot;</td><td>&quot;58 PLACE&quot;</td><td>&quot;59 STREET&quot;</td><td>null</td><td>null</td><td>&quot;BLOCKFACE&quot;</td><td>&quot;MASPETH&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Open&quot;</td><td>&quot;10/31/2013 10:01:04 AM&quot;</td><td>null</td><td>&quot;05 QUEENS&quot;</td><td>&quot;QUEENS&quot;</td><td>1009349</td><td>201984</td><td>&quot;Unspecified&quot;</td><td>&quot;QUEENS&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.721041</td><td>-73.909453</td><td>&quot;(40.721040535628305, -73.90945…</td></tr><tr><td>26594139</td><td>&quot;10/31/2013 02:00:24 AM&quot;</td><td>&quot;10/31/2013 02:40:32 AM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Commercial&quot;</td><td>&quot;Loud Music/Party&quot;</td><td>&quot;Club/Bar/Restaurant&quot;</td><td>&quot;10032&quot;</td><td>&quot;4060 BROADWAY&quot;</td><td>&quot;BROADWAY&quot;</td><td>&quot;WEST 171 STREET&quot;</td><td>&quot;WEST 172 STREET&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;NEW YORK&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 10:00:24 AM&quot;</td><td>&quot;10/31/2013 02:39:42 AM&quot;</td><td>&quot;12 MANHATTAN&quot;</td><td>&quot;MANHATTAN&quot;</td><td>1001088</td><td>246531</td><td>&quot;Unspecified&quot;</td><td>&quot;MANHATTAN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.84333</td><td>-73.939144</td><td>&quot;(40.84332975466513, -73.939143…</td></tr><tr><td>26595721</td><td>&quot;10/31/2013 01:56:23 AM&quot;</td><td>&quot;10/31/2013 02:21:48 AM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Vehicle&quot;</td><td>&quot;Car/Truck Horn&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;10023&quot;</td><td>&quot;WEST 72 STREET&quot;</td><td>&quot;WEST 72 STREET&quot;</td><td>&quot;COLUMBUS AVENUE&quot;</td><td>&quot;AMSTERDAM AVENUE&quot;</td><td>null</td><td>null</td><td>&quot;BLOCKFACE&quot;</td><td>&quot;NEW YORK&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 09:56:23 AM&quot;</td><td>&quot;10/31/2013 02:21:10 AM&quot;</td><td>&quot;07 MANHATTAN&quot;</td><td>&quot;MANHATTAN&quot;</td><td>989730</td><td>222727</td><td>&quot;Unspecified&quot;</td><td>&quot;MANHATTAN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.778009</td><td>-73.980213</td><td>&quot;(40.7780087446372, -73.9802134…</td></tr><tr><td>26590930</td><td>&quot;10/31/2013 01:53:44 AM&quot;</td><td>null</td><td>&quot;DOHMH&quot;</td><td>&quot;Department of Health and Menta…</td><td>&quot;Rodent&quot;</td><td>&quot;Condition Attracting Rodents&quot;</td><td>&quot;Vacant Lot&quot;</td><td>&quot;10027&quot;</td><td>&quot;WEST 124 STREET&quot;</td><td>&quot;WEST 124 STREET&quot;</td><td>&quot;LENOX AVENUE&quot;</td><td>&quot;ADAM CLAYTON POWELL JR BOULEVA…</td><td>null</td><td>null</td><td>&quot;BLOCKFACE&quot;</td><td>&quot;NEW YORK&quot;</td><td>null</td><td>&quot;N/A&quot;</td><td>&quot;Pending&quot;</td><td>&quot;11/30/2013 01:53:44 AM&quot;</td><td>&quot;10/31/2013 01:59:54 AM&quot;</td><td>&quot;10 MANHATTAN&quot;</td><td>&quot;MANHATTAN&quot;</td><td>998815</td><td>233545</td><td>&quot;Unspecified&quot;</td><td>&quot;MANHATTAN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.807691</td><td>-73.947387</td><td>&quot;(40.80769092704951, -73.947387…</td></tr></tbody></table></div>



# 2.2 Selecting a single column (a Series)

Polars offers two methods to get a single column (ie, a pl.Series object). The robust and functional way is to use the `df.get_column` function, but you can also use the [] syntax to save a few keystrokes. The reason why `df.get_column` is more robust is that `df.get_column` will always return a `Series` whereas indexing with [] may return a `Series` or `DataFrame` depending on the input.


```python
single_column = complaints.get_column('Complaint Type') # can also use complaints['Complaint Type']
display(type(single_column))
display(single_column)
```


    polars.series.series.Series



<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (111_069,)</small><table border="1" class="dataframe"><thead><tr><th>Complaint Type</th></tr><tr><td>str</td></tr></thead><tbody><tr><td>&quot;Noise - Street/Sidewalk&quot;</td></tr><tr><td>&quot;Illegal Parking&quot;</td></tr><tr><td>&quot;Noise - Commercial&quot;</td></tr><tr><td>&quot;Noise - Vehicle&quot;</td></tr><tr><td>&quot;Rodent&quot;</td></tr><tr><td>&hellip;</td></tr><tr><td>&quot;Maintenance or Facility&quot;</td></tr><tr><td>&quot;Illegal Parking&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td></tr><tr><td>&quot;Noise - Commercial&quot;</td></tr><tr><td>&quot;Blocked Driveway&quot;</td></tr></tbody></table></div>


`Series` objects also have a `head` function:


```python
complaints['Complaint Type'].head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (10,)</small><table border="1" class="dataframe"><thead><tr><th>Complaint Type</th></tr><tr><td>str</td></tr></thead><tbody><tr><td>&quot;Noise - Street/Sidewalk&quot;</td></tr><tr><td>&quot;Illegal Parking&quot;</td></tr><tr><td>&quot;Noise - Commercial&quot;</td></tr><tr><td>&quot;Noise - Vehicle&quot;</td></tr><tr><td>&quot;Rodent&quot;</td></tr><tr><td>&quot;Noise - Commercial&quot;</td></tr><tr><td>&quot;Blocked Driveway&quot;</td></tr><tr><td>&quot;Noise - Commercial&quot;</td></tr><tr><td>&quot;Noise - Commercial&quot;</td></tr><tr><td>&quot;Noise - Commercial&quot;</td></tr></tbody></table></div>



# 2.3 Selecting multiple columns (a DataFrame)

What if we just want to know the complaint type and the borough, but not the rest of the information? Polars provides the `df.select` method to select multiple columns. This method always returns a DataFrame.


```python
complaints.select('Complaint Type', 'Borough').head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 2)</small><table border="1" class="dataframe"><thead><tr><th>Complaint Type</th><th>Borough</th></tr><tr><td>str</td><td>str</td></tr></thead><tbody><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;QUEENS&quot;</td></tr><tr><td>&quot;Illegal Parking&quot;</td><td>&quot;QUEENS&quot;</td></tr><tr><td>&quot;Noise - Commercial&quot;</td><td>&quot;MANHATTAN&quot;</td></tr><tr><td>&quot;Noise - Vehicle&quot;</td><td>&quot;MANHATTAN&quot;</td></tr><tr><td>&quot;Rodent&quot;</td><td>&quot;MANHATTAN&quot;</td></tr></tbody></table></div>



The `polars.selectors` module (imported as `cs`) offers a powerful syntax for fine-tuned column selection. Here, we select the `Created Date` column along with all columns with "School" in their name.


```python
complaints.select('Created Date', cs.contains('School')).head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 12)</small><table border="1" class="dataframe"><thead><tr><th>Created Date</th><th>School Name</th><th>School Number</th><th>School Region</th><th>School Code</th><th>School Phone Number</th><th>School Address</th><th>School City</th><th>School State</th><th>School Zip</th><th>School Not Found</th><th>School or Citywide Complaint</th></tr><tr><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>&quot;10/31/2013 02:08:41 AM&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td></tr><tr><td>&quot;10/31/2013 02:01:04 AM&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td></tr><tr><td>&quot;10/31/2013 02:00:24 AM&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td></tr><tr><td>&quot;10/31/2013 01:56:23 AM&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td></tr><tr><td>&quot;10/31/2013 01:53:44 AM&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td></tr></tbody></table></div>



# 2.4 What's the most common complaint type?

This is a really easy question to answer! There's a `value_counts()` method that we can use:


```python
complaints['Complaint Type'].value_counts(sort=True)
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (165, 2)</small><table border="1" class="dataframe"><thead><tr><th>Complaint Type</th><th>count</th></tr><tr><td>str</td><td>u32</td></tr></thead><tbody><tr><td>&quot;HEATING&quot;</td><td>14200</td></tr><tr><td>&quot;GENERAL CONSTRUCTION&quot;</td><td>7471</td></tr><tr><td>&quot;Street Light Condition&quot;</td><td>7117</td></tr><tr><td>&quot;DOF Literature Request&quot;</td><td>5797</td></tr><tr><td>&quot;PLUMBING&quot;</td><td>5373</td></tr><tr><td>&hellip;</td><td>&hellip;</td></tr><tr><td>&quot;Open Flame Permit&quot;</td><td>1</td></tr><tr><td>&quot;DWD&quot;</td><td>1</td></tr><tr><td>&quot;Highway Sign - Damaged&quot;</td><td>1</td></tr><tr><td>&quot;Ferry Permit&quot;</td><td>1</td></tr><tr><td>&quot;X-Ray Machine/Equipment&quot;</td><td>1</td></tr></tbody></table></div>



If we just wanted the top 10 most common complaints, we can use the `top_k` function like so:


```python
complaint_counts = complaints['Complaint Type'].value_counts().top_k(10, by='count')
complaint_counts
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (10, 2)</small><table border="1" class="dataframe"><thead><tr><th>Complaint Type</th><th>count</th></tr><tr><td>str</td><td>u32</td></tr></thead><tbody><tr><td>&quot;HEATING&quot;</td><td>14200</td></tr><tr><td>&quot;GENERAL CONSTRUCTION&quot;</td><td>7471</td></tr><tr><td>&quot;Street Light Condition&quot;</td><td>7117</td></tr><tr><td>&quot;DOF Literature Request&quot;</td><td>5797</td></tr><tr><td>&quot;PLUMBING&quot;</td><td>5373</td></tr><tr><td>&quot;PAINT - PLASTER&quot;</td><td>5149</td></tr><tr><td>&quot;Blocked Driveway&quot;</td><td>4590</td></tr><tr><td>&quot;NONCONST&quot;</td><td>3998</td></tr><tr><td>&quot;Street Condition&quot;</td><td>3473</td></tr><tr><td>&quot;Illegal Parking&quot;</td><td>3343</td></tr></tbody></table></div>



But it gets better! We can plot them!


```python
plt.xticks(rotation=45)
sbn.barplot(complaint_counts, x='Complaint Type', y='count')
```




    <Axes: xlabel='Complaint Type', ylabel='count'>




    
![png](Chapter%202%20-%20Selecting%20data%20%26%20finding%20the%20most%20common%20complaint%20type_files/Chapter%202%20-%20Selecting%20data%20%26%20finding%20the%20most%20common%20complaint%20type_23_1.png)
    


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
