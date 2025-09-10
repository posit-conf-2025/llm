```python
import polars as pl
import polars.selectors as cs
print(pl.__version__)
```

    1.6.0


# 8.1 Parsing Unix timestamps

The columns in polars dataframes are statically typed, meaning there is no ambiguity regarding parsing data as integers or as dates. The file we're using here is a popularity-contest file I found on my system at `/var/log/popularity-contest`.

Here's an [explanation of how this file works](http://popcon.ubuntu.com/README).


```python
# Read it, and remove the last row
popcon = (
    pl.read_csv('../data/popularity-contest',
                separator=' ',
                ignore_errors=True,
                new_columns=['atime', 'ctime', 'package-name', 'mru-program', 'tag'])
    .filter(~pl.all_horizontal(pl.all().is_null()))
)
popcon.shape
```




    (2897, 5)



The colums are the access time, created time, package name, recently used program, and a tag. In this case, polars has parsed the access time and created time as integers instead of datetimes.


```python
popcon.head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 5)</small><table border="1" class="dataframe"><thead><tr><th>atime</th><th>ctime</th><th>package-name</th><th>mru-program</th><th>tag</th></tr><tr><td>i64</td><td>i64</td><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>1387295797</td><td>1367633260</td><td>&quot;perl-base&quot;</td><td>&quot;/usr/bin/perl&quot;</td><td>null</td></tr><tr><td>1387295796</td><td>1354370480</td><td>&quot;login&quot;</td><td>&quot;/bin/su&quot;</td><td>null</td></tr><tr><td>1387295743</td><td>1354341275</td><td>&quot;libtalloc2&quot;</td><td>&quot;/usr/lib/x86_64-linux-gnu/libt…</td><td>null</td></tr><tr><td>1387295743</td><td>1387224204</td><td>&quot;libwbclient0&quot;</td><td>&quot;/usr/lib/x86_64-linux-gnu/libw…</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>1387295742</td><td>1354341253</td><td>&quot;libselinux1&quot;</td><td>&quot;/lib/x86_64-linux-gnu/libselin…</td><td>null</td></tr></tbody></table></div>



We can explicitly convert the integers to datetimes using the `from_epoch` function:


```python
popcon = popcon.with_columns(
    pl.from_epoch('atime', time_unit='s'),
    pl.from_epoch('ctime') #time_unit='s' is default
)
```

If we look at the dtype now, it's `pl.Datetime`.


```python
popcon['atime'].dtype
```




    Datetime(time_unit='us', time_zone=None)



So now we can look at our `atime` and `ctime` as dates!


```python
popcon.head()
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (5, 5)</small><table border="1" class="dataframe"><thead><tr><th>atime</th><th>ctime</th><th>package-name</th><th>mru-program</th><th>tag</th></tr><tr><td>datetime[μs]</td><td>datetime[μs]</td><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>2013-12-17 15:56:37</td><td>2013-05-04 02:07:40</td><td>&quot;perl-base&quot;</td><td>&quot;/usr/bin/perl&quot;</td><td>null</td></tr><tr><td>2013-12-17 15:56:36</td><td>2012-12-01 14:01:20</td><td>&quot;login&quot;</td><td>&quot;/bin/su&quot;</td><td>null</td></tr><tr><td>2013-12-17 15:55:43</td><td>2012-12-01 05:54:35</td><td>&quot;libtalloc2&quot;</td><td>&quot;/usr/lib/x86_64-linux-gnu/libt…</td><td>null</td></tr><tr><td>2013-12-17 15:55:43</td><td>2013-12-16 20:03:24</td><td>&quot;libwbclient0&quot;</td><td>&quot;/usr/lib/x86_64-linux-gnu/libw…</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-17 15:55:42</td><td>2012-12-01 05:54:13</td><td>&quot;libselinux1&quot;</td><td>&quot;/lib/x86_64-linux-gnu/libselin…</td><td>null</td></tr></tbody></table></div>



Now suppose we want to look at all packages that aren't libraries. First, I want to get rid of everything with timestamp 0.


```python
print("before filter")
display(popcon.bottom_k(3, by='atime'))
popcon = popcon.filter(
    pl.col('atime') > pl.datetime(1970, 1, 1)
)
print("after filter")
display(popcon.bottom_k(3, by='atime'))
```

    before filter



<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 5)</small><table border="1" class="dataframe"><thead><tr><th>atime</th><th>ctime</th><th>package-name</th><th>mru-program</th><th>tag</th></tr><tr><td>datetime[μs]</td><td>datetime[μs]</td><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>1970-01-01 00:00:00</td><td>1970-01-01 00:00:00</td><td>&quot;librsync1&quot;</td><td>&quot;&lt;NOFILES&gt;&quot;</td><td>null</td></tr><tr><td>1970-01-01 00:00:00</td><td>1970-01-01 00:00:00</td><td>&quot;libindicator-messages-status-p…</td><td>&quot;&lt;NOFILES&gt;&quot;</td><td>null</td></tr><tr><td>1970-01-01 00:00:00</td><td>1970-01-01 00:00:00</td><td>&quot;libxfconf-0-2&quot;</td><td>&quot;&lt;NOFILES&gt;&quot;</td><td>null</td></tr></tbody></table></div>


    after filter



<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 5)</small><table border="1" class="dataframe"><thead><tr><th>atime</th><th>ctime</th><th>package-name</th><th>mru-program</th><th>tag</th></tr><tr><td>datetime[μs]</td><td>datetime[μs]</td><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>2008-11-20 14:38:20</td><td>2012-12-01 05:54:57</td><td>&quot;libfile-copy-recursive-perl&quot;</td><td>&quot;/usr/share/perl5/File/Copy/Rec…</td><td>&quot;&lt;OLD&gt;&quot;</td></tr><tr><td>2010-02-22 14:59:21</td><td>2012-12-01 05:54:14</td><td>&quot;libfribidi0&quot;</td><td>&quot;/usr/bin/fribidi&quot;</td><td>&quot;&lt;OLD&gt;&quot;</td></tr><tr><td>2010-03-06 14:44:18</td><td>2012-12-01 05:54:37</td><td>&quot;laptop-detect&quot;</td><td>&quot;/usr/sbin/laptop-detect&quot;</td><td>&quot;&lt;OLD&gt;&quot;</td></tr></tbody></table></div>


Now we can use polars' `filter` and `str` look at rows where the package name doesn't contain 'lib'.


```python
nonlibraries = popcon.filter(
    ~pl.col('package-name').str.contains('lib')
)
nonlibraries.top_k(10, by='ctime')
```




<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (10, 5)</small><table border="1" class="dataframe"><thead><tr><th>atime</th><th>ctime</th><th>package-name</th><th>mru-program</th><th>tag</th></tr><tr><td>datetime[μs]</td><td>datetime[μs]</td><td>str</td><td>str</td><td>str</td></tr></thead><tbody><tr><td>2013-12-17 04:55:39</td><td>2013-12-17 04:55:42</td><td>&quot;ddd&quot;</td><td>&quot;/usr/bin/ddd&quot;</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:03:20</td><td>2013-12-16 20:05:13</td><td>&quot;nodejs&quot;</td><td>&quot;/usr/bin/npm&quot;</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:03:20</td><td>2013-12-16 20:05:04</td><td>&quot;switchboard-plug-keyboard&quot;</td><td>&quot;/usr/lib/plugs/pantheon/keyboa…</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:03:20</td><td>2013-12-16 20:05:04</td><td>&quot;thunderbird-locale-en&quot;</td><td>&quot;/usr/lib/thunderbird-addons/ex…</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:08:27</td><td>2013-12-16 20:05:03</td><td>&quot;software-center&quot;</td><td>&quot;/usr/sbin/update-software-cent…</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:03:20</td><td>2013-12-16 20:05:00</td><td>&quot;samba-common-bin&quot;</td><td>&quot;/usr/bin/net.samba3&quot;</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:08:25</td><td>2013-12-16 20:04:59</td><td>&quot;postgresql-client-9.1&quot;</td><td>&quot;/usr/lib/postgresql/9.1/bin/ps…</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:08:23</td><td>2013-12-16 20:04:58</td><td>&quot;postgresql-9.1&quot;</td><td>&quot;/usr/lib/postgresql/9.1/bin/po…</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:03:20</td><td>2013-12-16 20:04:55</td><td>&quot;php5-dev&quot;</td><td>&quot;/usr/include/php5/main/snprint…</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr><tr><td>2013-12-16 20:03:20</td><td>2013-12-16 20:04:54</td><td>&quot;php-pear&quot;</td><td>&quot;/usr/share/php/XML/Util.php&quot;</td><td>&quot;&lt;RECENT-CTIME&gt;&quot;</td></tr></tbody></table></div>


