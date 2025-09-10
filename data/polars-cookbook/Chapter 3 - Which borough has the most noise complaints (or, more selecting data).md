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


Let's continue with our NYC 311 service requests example.


```python
# because of mixed types we specify dtype to prevent any errors
complaints = pl.read_csv('../data/311-service-requests.csv', schema_overrides={'Incident Zip':pl.String})
```

# 3.1 Selecting only noise complaints

I'd like to know which borough has the most noise complaints. First, we'll take a look at the data to see what it looks like:


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



To get the noise complaints, we need to find the rows where the "Complaint Type" column is "Noise - Street/Sidewalk". I'll show you how to do that, and then explain what's going on.


```python
noise_complaints = complaints.filter(pl.col('Complaint Type') == "Noise - Street/Sidewalk")
noise_complaints.head(3)
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 52)</small><table border="1" class="dataframe"><thead><tr><th>Unique Key</th><th>Created Date</th><th>Closed Date</th><th>Agency</th><th>Agency Name</th><th>Complaint Type</th><th>Descriptor</th><th>Location Type</th><th>Incident Zip</th><th>Incident Address</th><th>Street Name</th><th>Cross Street 1</th><th>Cross Street 2</th><th>Intersection Street 1</th><th>Intersection Street 2</th><th>Address Type</th><th>City</th><th>Landmark</th><th>Facility Type</th><th>Status</th><th>Due Date</th><th>Resolution Action Updated Date</th><th>Community Board</th><th>Borough</th><th>X Coordinate (State Plane)</th><th>Y Coordinate (State Plane)</th><th>Park Facility Name</th><th>Park Borough</th><th>School Name</th><th>School Number</th><th>School Region</th><th>School Code</th><th>School Phone Number</th><th>School Address</th><th>School City</th><th>School State</th><th>School Zip</th><th>School Not Found</th><th>School or Citywide Complaint</th><th>Vehicle Type</th><th>Taxi Company Borough</th><th>Taxi Pick Up Location</th><th>Bridge Highway Name</th><th>Bridge Highway Direction</th><th>Road Ramp</th><th>Bridge Highway Segment</th><th>Garage Lot Name</th><th>Ferry Direction</th><th>Ferry Terminal Name</th><th>Latitude</th><th>Longitude</th><th>Location</th></tr><tr><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>i64</td><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>26589651</td><td>&quot;10/31/2013 02:08:41 AM&quot;</td><td>null</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Talking&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11432&quot;</td><td>&quot;90-03 169 STREET&quot;</td><td>&quot;169 STREET&quot;</td><td>&quot;90 AVENUE&quot;</td><td>&quot;91 AVENUE&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;JAMAICA&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Assigned&quot;</td><td>&quot;10/31/2013 10:08:41 AM&quot;</td><td>&quot;10/31/2013 02:35:17 AM&quot;</td><td>&quot;12 QUEENS&quot;</td><td>&quot;QUEENS&quot;</td><td>1042027</td><td>197389</td><td>&quot;Unspecified&quot;</td><td>&quot;QUEENS&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.708275</td><td>-73.791604</td><td>&quot;(40.70827532593202, -73.791603…</td></tr><tr><td>26594086</td><td>&quot;10/31/2013 12:54:03 AM&quot;</td><td>&quot;10/31/2013 02:16:39 AM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Music/Party&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;10310&quot;</td><td>&quot;173 CAMPBELL AVENUE&quot;</td><td>&quot;CAMPBELL AVENUE&quot;</td><td>&quot;HENDERSON AVENUE&quot;</td><td>&quot;WINEGAR LANE&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;STATEN ISLAND&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 08:54:03 AM&quot;</td><td>&quot;10/31/2013 02:07:14 AM&quot;</td><td>&quot;01 STATEN ISLAND&quot;</td><td>&quot;STATEN ISLAND&quot;</td><td>952013</td><td>171076</td><td>&quot;Unspecified&quot;</td><td>&quot;STATEN ISLAND&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.636182</td><td>-74.11615</td><td>&quot;(40.63618202176914, -74.116150…</td></tr><tr><td>26591573</td><td>&quot;10/31/2013 12:35:18 AM&quot;</td><td>&quot;10/31/2013 02:41:35 AM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Talking&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;10312&quot;</td><td>&quot;24 PRINCETON LANE&quot;</td><td>&quot;PRINCETON LANE&quot;</td><td>&quot;HAMPTON GREEN&quot;</td><td>&quot;DEAD END&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;STATEN ISLAND&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 08:35:18 AM&quot;</td><td>&quot;10/31/2013 01:45:17 AM&quot;</td><td>&quot;03 STATEN ISLAND&quot;</td><td>&quot;STATEN ISLAND&quot;</td><td>929577</td><td>140964</td><td>&quot;Unspecified&quot;</td><td>&quot;STATEN ISLAND&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.553421</td><td>-74.196743</td><td>&quot;(40.55342078716953, -74.196743…</td></tr></tbody></table></div>



If you look at `noise_complaints`, you'll see that this worked, and it only contains complaints with the right complaint type. But how does this work? Let's deconstruct it into two pieces


```python
pl.col('Complaint Type') == "Noise - Street/Sidewalk"
```




[(col("Complaint Type")) == (String(Noise - Street/Sidewalk))]



This is a polars expression, which represents a transformation of Series. In this case, this expression represents a mapping from 'Complaint Type' Series (a str) to a boolean Series based on the predecate. The "filter" function will take in any expression which evaluates to a boolean Series.

You can also store and combine more than one expression with the `&` operator like this:


```python
is_noise = pl.col('Complaint Type') == "Noise - Street/Sidewalk"
in_brooklyn = pl.col('Borough') == "BROOKLYN"
complaints.filter(is_noise & in_brooklyn).head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 52)</small><table border="1" class="dataframe"><thead><tr><th>Unique Key</th><th>Created Date</th><th>Closed Date</th><th>Agency</th><th>Agency Name</th><th>Complaint Type</th><th>Descriptor</th><th>Location Type</th><th>Incident Zip</th><th>Incident Address</th><th>Street Name</th><th>Cross Street 1</th><th>Cross Street 2</th><th>Intersection Street 1</th><th>Intersection Street 2</th><th>Address Type</th><th>City</th><th>Landmark</th><th>Facility Type</th><th>Status</th><th>Due Date</th><th>Resolution Action Updated Date</th><th>Community Board</th><th>Borough</th><th>X Coordinate (State Plane)</th><th>Y Coordinate (State Plane)</th><th>Park Facility Name</th><th>Park Borough</th><th>School Name</th><th>School Number</th><th>School Region</th><th>School Code</th><th>School Phone Number</th><th>School Address</th><th>School City</th><th>School State</th><th>School Zip</th><th>School Not Found</th><th>School or Citywide Complaint</th><th>Vehicle Type</th><th>Taxi Company Borough</th><th>Taxi Pick Up Location</th><th>Bridge Highway Name</th><th>Bridge Highway Direction</th><th>Road Ramp</th><th>Bridge Highway Segment</th><th>Garage Lot Name</th><th>Ferry Direction</th><th>Ferry Terminal Name</th><th>Latitude</th><th>Longitude</th><th>Location</th></tr><tr><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>i64</td><td>i64</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>str</td></tr></thead><tbody><tr><td>26595564</td><td>&quot;10/31/2013 12:30:36 AM&quot;</td><td>null</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Music/Party&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11236&quot;</td><td>&quot;AVENUE J&quot;</td><td>&quot;AVENUE J&quot;</td><td>&quot;EAST 80 STREET&quot;</td><td>&quot;EAST 81 STREET&quot;</td><td>null</td><td>null</td><td>&quot;BLOCKFACE&quot;</td><td>&quot;BROOKLYN&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Open&quot;</td><td>&quot;10/31/2013 08:30:36 AM&quot;</td><td>null</td><td>&quot;18 BROOKLYN&quot;</td><td>&quot;BROOKLYN&quot;</td><td>1008937</td><td>170310</td><td>&quot;Unspecified&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.634104</td><td>-73.911055</td><td>&quot;(40.634103775951736, -73.91105…</td></tr><tr><td>26595553</td><td>&quot;10/31/2013 12:05:10 AM&quot;</td><td>&quot;10/31/2013 02:43:43 AM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Talking&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11225&quot;</td><td>&quot;25 LEFFERTS AVENUE&quot;</td><td>&quot;LEFFERTS AVENUE&quot;</td><td>&quot;WASHINGTON AVENUE&quot;</td><td>&quot;BEDFORD AVENUE&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;BROOKLYN&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 08:05:10 AM&quot;</td><td>&quot;10/31/2013 01:29:29 AM&quot;</td><td>&quot;09 BROOKLYN&quot;</td><td>&quot;BROOKLYN&quot;</td><td>995366</td><td>180388</td><td>&quot;Unspecified&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.661793</td><td>-73.959934</td><td>&quot;(40.6617931276793, -73.9599336…</td></tr><tr><td>26594653</td><td>&quot;10/30/2013 11:26:32 PM&quot;</td><td>&quot;10/31/2013 12:18:54 AM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Music/Party&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11222&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;DOBBIN STREET&quot;</td><td>&quot;NORMAN STREET&quot;</td><td>&quot;INTERSECTION&quot;</td><td>&quot;BROOKLYN&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 07:26:32 AM&quot;</td><td>&quot;10/31/2013 12:18:54 AM&quot;</td><td>&quot;01 BROOKLYN&quot;</td><td>&quot;BROOKLYN&quot;</td><td>996925</td><td>203271</td><td>&quot;Unspecified&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.7246</td><td>-73.954271</td><td>&quot;(40.724599563793525, -73.95427…</td></tr><tr><td>26591992</td><td>&quot;10/30/2013 10:02:58 PM&quot;</td><td>&quot;10/30/2013 10:23:20 PM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Talking&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11218&quot;</td><td>&quot;DITMAS AVENUE&quot;</td><td>&quot;DITMAS AVENUE&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>&quot;LATLONG&quot;</td><td>&quot;BROOKLYN&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 06:02:58 AM&quot;</td><td>&quot;10/30/2013 10:23:20 PM&quot;</td><td>&quot;01 BROOKLYN&quot;</td><td>&quot;BROOKLYN&quot;</td><td>991895</td><td>171051</td><td>&quot;Unspecified&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.636169</td><td>-73.972455</td><td>&quot;(40.63616876563881, -73.972455…</td></tr><tr><td>26594167</td><td>&quot;10/30/2013 08:38:25 PM&quot;</td><td>&quot;10/30/2013 10:26:28 PM&quot;</td><td>&quot;NYPD&quot;</td><td>&quot;New York City Police Departmen…</td><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;Loud Music/Party&quot;</td><td>&quot;Street/Sidewalk&quot;</td><td>&quot;11218&quot;</td><td>&quot;126 BEVERLY ROAD&quot;</td><td>&quot;BEVERLY ROAD&quot;</td><td>&quot;CHURCH AVENUE&quot;</td><td>&quot;EAST 2 STREET&quot;</td><td>null</td><td>null</td><td>&quot;ADDRESS&quot;</td><td>&quot;BROOKLYN&quot;</td><td>null</td><td>&quot;Precinct&quot;</td><td>&quot;Closed&quot;</td><td>&quot;10/31/2013 04:38:25 AM&quot;</td><td>&quot;10/30/2013 10:26:28 PM&quot;</td><td>&quot;12 BROOKLYN&quot;</td><td>&quot;BROOKLYN&quot;</td><td>990144</td><td>173511</td><td>&quot;Unspecified&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;Unspecified&quot;</td><td>&quot;N&quot;</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>null</td><td>40.642922</td><td>-73.978762</td><td>&quot;(40.6429222774404, -73.9787617…</td></tr></tbody></table></div>



Or if we just wanted a few columns:


```python
complaints.filter(is_noise & in_brooklyn).select('Complaint Type', 'Borough', 'Created Date', 'Descriptor').head(10)
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (10, 4)</small><table border="1" class="dataframe"><thead><tr><th>Complaint Type</th><th>Borough</th><th>Created Date</th><th>Descriptor</th></tr><tr><td>str</td><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/31/2013 12:30:36 AM&quot;</td><td>&quot;Loud Music/Party&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/31/2013 12:05:10 AM&quot;</td><td>&quot;Loud Talking&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/30/2013 11:26:32 PM&quot;</td><td>&quot;Loud Music/Party&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/30/2013 10:02:58 PM&quot;</td><td>&quot;Loud Talking&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/30/2013 08:38:25 PM&quot;</td><td>&quot;Loud Music/Party&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/30/2013 08:32:13 PM&quot;</td><td>&quot;Loud Talking&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/30/2013 06:07:39 PM&quot;</td><td>&quot;Loud Music/Party&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/30/2013 03:04:51 PM&quot;</td><td>&quot;Loud Talking&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/29/2013 10:07:02 PM&quot;</td><td>&quot;Loud Talking&quot;</td></tr><tr><td>&quot;Noise - Street/Sidewalk&quot;</td><td>&quot;BROOKLYN&quot;</td><td>&quot;10/29/2013 08:15:59 PM&quot;</td><td>&quot;Loud Music/Party&quot;</td></tr></tbody></table></div>



# 3.2 So, which borough has the most noise complaints?


```python
noise_complaints = complaints.filter(pl.col('Complaint Type') == "Noise - Street/Sidewalk")
noise_complaints['Borough'].value_counts(sort=True)
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (6, 2)</small><table border="1" class="dataframe"><thead><tr><th>Borough</th><th>count</th></tr><tr><td>str</td><td>u32</td></tr></thead><tbody><tr><td>&quot;MANHATTAN&quot;</td><td>917</td></tr><tr><td>&quot;BROOKLYN&quot;</td><td>456</td></tr><tr><td>&quot;BRONX&quot;</td><td>292</td></tr><tr><td>&quot;QUEENS&quot;</td><td>226</td></tr><tr><td>&quot;STATEN ISLAND&quot;</td><td>36</td></tr><tr><td>&quot;Unspecified&quot;</td><td>1</td></tr></tbody></table></div>



It's Manhattan! But Manhattan probably has a lot of complaints in total. Maybe it's better to get the percentage of all complaints that are noise complaints? That would be easy too with the `group_by` method:


```python
complaint_avgs = (
    complaints
    .group_by("Borough")
    .agg(noise_complaint_avg=(pl.col('Complaint Type') == "Noise - Street/Sidewalk").mean())
    .sort('noise_complaint_avg', descending=True)
)
complaint_avgs
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (6, 2)</small><table border="1" class="dataframe"><thead><tr><th>Borough</th><th>noise_complaint_avg</th></tr><tr><td>str</td><td>f64</td></tr></thead><tbody><tr><td>&quot;MANHATTAN&quot;</td><td>0.037755</td></tr><tr><td>&quot;BRONX&quot;</td><td>0.014833</td></tr><tr><td>&quot;BROOKLYN&quot;</td><td>0.013864</td></tr><tr><td>&quot;QUEENS&quot;</td><td>0.010143</td></tr><tr><td>&quot;STATEN ISLAND&quot;</td><td>0.007474</td></tr><tr><td>&quot;Unspecified&quot;</td><td>0.000141</td></tr></tbody></table></div>



It looks like noise complaints make up about 3.7% of all complaints in Manhattan. Which isn't a lot, but it's still leading amongst all boroughs.


```python
sbn.barplot(complaint_avgs, x='Borough', y='noise_complaint_avg')
```




    <Axes: xlabel='Borough', ylabel='noise_complaint_avg'>




    
![png](Chapter%203%20-%20Which%20borough%20has%20the%20most%20noise%20complaints%20%28or%2C%20more%20selecting%20data%29_files/Chapter%203%20-%20Which%20borough%20has%20the%20most%20noise%20complaints%20%28or%2C%20more%20selecting%20data%29_19_1.png)
    


So Manhattan really does complain more about noise than the other boroughs! Neat.

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
