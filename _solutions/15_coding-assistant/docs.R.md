<README src="https://github.com/JeffreyFowler/weathR/blob/master/README.md">
# weathR

<!-- badges: start -->
<!-- badges: end -->

The goal of this package is to facilitate easy interaction with the
National Weather Service API in R!

## Installation

You can install the development version of weathR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("JeffreyFowler/weathR")
```

Or, you can get the official release version from CRAN:

``` r
install.packages("weathR")
```

## Fetching NWS Metadata for a Location

The function `point_data()` allows the user to fetch NWS metadata for a
specific point as a dataframe.

``` r
library(weathR)
library(dplyr)
#>
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#>
#>     filter, lag
#> The following objects are masked from 'package:base':
#>
#>     intersect, setdiff, setequal, union
```

``` r
library(sf) #This is used later in our documentation
#> Warning: package 'sf' was built under R version 4.4.2
#> Linking to GEOS 3.12.2, GDAL 3.9.3, PROJ 9.4.1; sf_use_s2() is TRUE
```

``` r

# Using google maps, we find the coordinates for Central Park, NYC.
point_data(lat = 40.768472897200986, lon = -73.97600351884695) %>%
  as.data.frame() %>%
  head()
#>                                         endpoint cwa
#> 1 https://api.weather.gov/points/40.7685,-73.976 OKX
#>                       forecast_office grid_id grid_x grid_y
#> 1 https://api.weather.gov/offices/OKX     OKX     34     38
#>                                                forecast
#> 1 https://api.weather.gov/gridpoints/OKX/34,38/forecast
#>                                                forecast_hourly
#> 1 https://api.weather.gov/gridpoints/OKX/34,38/forecast/hourly
#>                             forecast_grid_data
#> 1 https://api.weather.gov/gridpoints/OKX/34,38
#>                                    observation_stations          city state
#> 1 https://api.weather.gov/gridpoints/OKX/34,38/stations West New York    NJ
#>                                   forecast_zone
#> 1 https://api.weather.gov/zones/forecast/NYZ072
#>                                        county
#> 1 https://api.weather.gov/zones/county/NYC061
#>                           fire_weather_zone        time_zone radar_station
#> 1 https://api.weather.gov/zones/fire/NYZ212 America/New_York          KOKX
#>                   geometry
#> 1 POINT (-73.976 40.76847)
```

## Fetching and Displaying Point Forecasts

``` r

# We can fetch forecast temperatures (in degrees fahrenheit) for NYC
point_forecast(lat = 40.768472897200986, lon = -73.97600351884695) %>%
  as.data.frame() %>%
  select(time, temp) %>%
  head()
#>                      time temp
#> 1 2025-03-31 17:00:00 EDT   72
#> 2 2025-03-31 18:00:00 EDT   69
#> 3 2025-03-31 19:00:00 EDT   67
#> 4 2025-03-31 20:00:00 EDT   66
#> 5 2025-03-31 21:00:00 EDT   65
#> 6 2025-03-31 22:00:00 EDT   64
```

``` r

# We can even produce a graph of the forecast
library(ggplot2)
#> Warning: package 'ggplot2' was built under R version 4.4.2
```

``` r

point_forecast(lat = 40.768472897200986, lon = -73.97600351884695) %>%
  as.data.frame() %>%
  select(time, temp) %>%
  mutate(time = as.POSIXct(time)) %>% #convert time to a POSIXct object
  ggplot(aes(x = time, y = temp)) +
  #Add points for forecast values of temperature
  geom_point(color = "brown") +
  #Add a smoothed line that follows the points
  geom_smooth(method = "loess", span = .15, se = FALSE, color = "indianred") +
  labs(
    title = paste0("KNYC Temperature Forecasts for the Week of ", Sys.Date()),
    y = "Temperature (Degrees Fahrenheit)",
    x = "Day"
  ) +
  theme_minimal()
#> `geom_smooth()` using formula = 'y ~ x'
```

<img src="man/figures/README-example2-1.png" width="100" />

## Fetching Station ID forecast values

Rather than using a latitude/longitude point, we can use an ASOS or AWOS
station identifier.

Lets get a list of the forecast wind speed, wind direction, and skies,
by time.

``` r

station_forecast(station_id = "KNYC") %>%
  as.data.frame() %>%
  select(time, wind_speed, skies) %>%
  head()
#>                      time wind_speed                            skies
#> 1 2025-03-31 17:00:00 EDT          9 Chance Showers And Thunderstorms
#> 2 2025-03-31 18:00:00 EDT          9 Showers And Thunderstorms Likely
#> 3 2025-03-31 19:00:00 EDT          8 Showers And Thunderstorms Likely
#> 4 2025-03-31 20:00:00 EDT          8        Showers And Thunderstorms
#> 5 2025-03-31 21:00:00 EDT          8        Showers And Thunderstorms
#> 6 2025-03-31 22:00:00 EDT          7        Showers And Thunderstorms
```

``` r

# We can easily put this result into a GT table for easy viewing
```

\<~– ![my_table](my_table.png) –\>

## Finding NWS ASOS/AWOS Stations Near a Point

There a number of different types of weather stations. An advantage of
the weathR package is the ability to easily find ASOS/AWOS stations used
the NWS near a given point. This is useful as these stations tend to
have better quality assurance practices than amateur meteorologist
stations.

``` r

#Using the coordinates for Denver, Colorado from google maps
stations_near(lat = 39.73331998845491, lon = -104.98209127042489) %>%
  as.data.frame() %>%
  head()
#>   station_id euc_dist                   geometry
#> 1       KBKF 13.49539 POINT (-104.7581 39.71331)
#> 2       KBJC 12.43745 POINT (-105.1042 39.90085)
#> 3       KAPA 13.13736 POINT (-104.8484 39.55991)
#> 4       KDEN 20.69956 POINT (-104.6562 39.84658)
#> 5       KEIK 17.19671 POINT (-105.0503 40.01169)
#> 6       KCFO 26.84118 POINT (-104.5376 39.78419)
```

``` r
#Or, viewing them plotted on an interactive map
library(tmap)
#> Warning: package 'tmap' was built under R version 4.4.2
#> Breaking News: tmap 3.x is retiring. Please test v4, e.g. with
#> remotes::install_github('r-tmap/tmap')
```

``` r
tmap::tmap_mode("view")
#> tmap mode set to interactive viewing
```

``` r
tmap::tmap_options(basemaps = c(Topo = "Esri.WorldTopoMap"))

stations_near(lat = 39.73331998845491, lon = -104.98209127042489) %>%
  tmap::tm_shape() +
  #Plot stations near our point, with color becoming darker as they get closer
  tmap::tm_dots(size = .08, col = "euc_dist", palette = "-Blues", title = "Euclidian Distance") +
  tmap::tm_shape(
    st_as_sf(
      data.frame(
        lon = -104.98209127042489,
        lat = 39.73331998845491
      ),
      coords = c("lon", "lat"),
      crs = 4326
    )
  ) +
  tmap::tm_dots(size = .08)
```

<img src="man/figures/README-example5E-1.png" width="100" /> [You can
click here to view the dynamic map we
created.](https://jeffreyfowler.github.io/weathR/dynamic_map.html)

This is just a sampling of the functionality available in this package.
Feel free to browse the documentation with the `?function` commands in
the R console to explore further!
</README>
