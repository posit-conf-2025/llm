<README src="https://github.com/Programer-Turtle/NWS/blob/main/README.md">
# NWS
A module that uses the National Weather Service's API to get weather data meaning no need for an account, or API token.

# Important
This program is not responsible if weather data is innacurate, nor should you rely on this program for emergency weather alerts!

# Install
```
pip install NWS
```

# Setup
Everyscript must start with the initiate API function. This requires you to put your applications name and a email to contact you. This is recommended by the national weather service for a better experience, but you can use the BypassInitiate function to skip this.

**Example on how to Initiate API**
```
import NWS as weather

#Location of NOAA headquarters in Washington DC
latitude = "38.89355704224317"
longitude = "-77.033268223003"

weather.InitiateAPI("AppName", "Email")
print(weather.GetCurrentTemperature(latitude, longitude))
```

**Example on how to Bypass API**
```
import NWS as weather

#Location of NOAA headquarters in Washington DC
latitude = "38.89355704224317"
longitude = "-77.033268223003"

weather.BypassInitiate()
print(weather.GetCurrentTemperature(latitude, longitude))
```

#Documentation
This is all the functions avaiable to you

**Get Hourly Forecast**
Returns the hourly forecast data from the NWS in a dictionary.

```
import NWS

#Location of NOAA headquarters in Washington DC
latitude = "38.89355704224317"
longitude = "-77.033268223003"
weather.InitiateAPI("AppName", "Email")

NWSweather.GetHourlyForecast(latitude, longitude)
```

**Get Current Forecast**
Returns the currently predicted forecast data from the NWS in a dictionary.

```
import NWS

#Location of NOAA headquarters in Washington DC
latitude = "38.89355704224317"
longitude = "-77.033268223003"
weather.InitiateAPI("AppName", "Email")

NWSweather.GetCurrentForecast(latitude, longitude)
```

**Get Current Conditions**
Returns the currently predicted conditions data from the NWS in a dictionary.

```
import NWS

#Location of NOAA headquarters in Washington DC
latitude = "38.89355704224317"
longitude = "-77.033268223003"
weather.InitiateAPI("AppName", "Email")

NWSweather.GetCurrentConditions(latitude, longitude)
```

**Get Current Temperature**
Returns the currently predicted temperature from the NWS.

```
import NWS

#Location of NOAA headquarters in Washington DC
latitude = "38.89355704224317"
longitude = "-77.033268223003"
weather.InitiateAPI("AppName", "Email")

NWSweather.GetCurrentTemperature(latitude, longitude)
```

**Get Current Wind Data**
Returns the currently predicted wind data from the NWS in a dictionary.

```
import NWS

#Location of NOAA headquarters in Washington DC
latitude = "38.89355704224317"
longitude = "-77.033268223003"
weather.InitiateAPI("AppName", "Email")

NWSweather.GetCurrentWindData(latitude, longitude)
```

**Get Current Weather Alerts**
Returns any active weather alert data in a dictionary, and will return null if no alerts.

```
import NWS

#Location of NOAA headquarters in Washington DC
latitude = "38.89355704224317"
longitude = "-77.033268223003"
weather.InitiateAPI("AppName", "Email")

NWSweather.GetWeatherAlerts(latitude, longitude)
```
</README>
