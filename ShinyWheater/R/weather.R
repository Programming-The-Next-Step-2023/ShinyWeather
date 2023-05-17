#make custom API string

weather_api <- function (latitude = 52.37, longitude = 4.89){
  root = "https://api.open-meteo.com/v1/forecast?"
  measures = "&hourly=temperature_2m&current_weather=true&hourly=windspeed_10m&hourly=rain&hourly=snowfall&hourly=precipitation&hourly=showers"
  my_api = paste0(root,"latitude=",latitude,"&longitude=",longitude, measures)
  return(my_api)
}

#function to get hourly weather for the next 7 days starting with current day
get_weather_now <- function(api = "https://api.open-meteo.com/v1/forecast?latitude=52.37&longitude=4.89&hourly=temperature_2m&current_weather=true&hourly=windspeed_10m&hourly=rain&hourly=snowfall&hourly=precipitation_probability"){
  
  # make the API request and get the result from it (res)
  #res <- httr::GET("https://api.open-meteo.com/v1/forecast?latitude=52.37&longitude=4.89&hourly=temperature_2m&current_weather=true&hourly=windspeed_10m&hourly=rain&hourly=snowfall&hourly=precipitation_probability")
  res <- httr::GET(api)
  
  # obtains data 
  data = jsonlite::fromJSON(rawToChar(res$content))
  return(data)
}

weather_data <- get_weather_now()
names(weather_data)
weather_data$current_weather

# To roxygen go to Code- Instert Roxygen Skeleton 

all_weather_data <- function(latitude = 52.37, longitude = 4.89, day_index = 0) {
  api <- weather_api(latitude, longitude)
  weather_data <- get_weather_now(api)
  
  # temp
  temperature_day <- round(mean(weather_data$hourly$temperature_2m[(day_index*24) + 1:(day_index*24) + 24]), 2)
  
  # wind
  wind_speed_day <- round(mean(weather_data$hourly$windspeed_10m[(day_index*24) + 1:(day_index*24) + 24]), 2)
  
  # shower
  showers_day <- round(mean(weather_data$hourly$showers[(day_index*24) + 1:(day_index*24) + 24]), 2)
  
  # snow
  snow_day <- round(mean(weather_data$hourly$snowfall[(day_index*24) + 1:(day_index*24) + 24]), 2)
  
  # rain
  rain_day <- round(mean(weather_data$hourly$rain[(day_index*24) + 1:(day_index*24) + 24]), 2)
  
  list('Temp' = temperature_day, 'Wind' = wind_speed_day, 'Showers' = showers_day, 'Snow' = snow_day, 'Rain' = rain_day)
}


################################################################################

# day_index is number of days from today (today being 0)
get_temperature <- function (day_index = 0){
  weather_data <- get_weather_now()
  temperature_day <- round(mean(weather_data$hourly$temperature_2m[(day_index*24) + 1:(day_index*24) + 24]), 2)
  return(temperature_day)
}


#function to get the temperature for today

get_temperature_today <- function (){
  weather_data <- get_weather_now()
  temperature_today <- round(mean(weather_data$hourly$temperature_2m[1:24]), 2)
  return(temperature_today)
}


#function to get the wind speed for today

get_wind_speed_today <- function (){
  weather_data <- get_weather_now()
  wind_speed_today <- round(mean(weather_data$hourly$windspeed_10m[1:24]), 2)
  return(wind_speed_today)
}



#function to get the amount of rain for today
get_rain_today <- function (){
  weather_data <- get_weather_now()
  rain_today <- round(mean(weather_data$hourly$rain[1:24]), 2)
  return(rain_today)
}

#function to get the probability of precipitations for today

get_precipitation_chance_today <- function (){
  weather_data <- get_weather_now()
  precipitation_chance_today <- round(mean(weather_data$hourly$precipitation_probability[1:24]), 2)
  return(precipitation_chance_today)
}

#function to get the amount of snowfall for today
get_snow_today <- function (){
  weather_data <- get_weather_now()
  snow_today <- round(mean(weather_data$hourly$snowfall[1:24]), 2)
  return(snow_today)
}







# Practice API

res <- httr::GET("https://api.open-meteo.com/v1/forecast?latitude=52.37&longitude=4.89&current_weather=true&daily=windspeed_10m&timezone=auto")

# obtains data 
data = jsonlite::fromJSON(rawToChar(res$content))
                          