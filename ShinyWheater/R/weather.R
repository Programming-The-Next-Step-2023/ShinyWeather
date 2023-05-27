#make custom API string
weather_api <- function (latitude = 52.37, longitude = 4.89){
  if (latitude >90 | latitude < -90){
    stop("Latitude inputed is outside the range [-90,90]")
  }
  if (longitude >180 | longitude < -180){
    stop("Longitude inputed is outside the range [-180,180]")
  }
  root = "https://api.open-meteo.com/v1/forecast?"
  measures = "&hourly=temperature_2m&current_weather=true&hourly=windspeed_10m&hourly=rain&hourly=snowfall&hourly=precipitation&hourly=showers"
  my_api = paste0(root,"latitude=",latitude,"&longitude=",longitude, measures)
  return(my_api)
}


#function to get hourly weather for the next 7 days starting with current day
get_weather_now <- function(api = "https://api.open-meteo.com/v1/forecast?latitude=52.37&longitude=4.89&hourly=temperature_2m&current_weather=true&hourly=windspeed_10m&hourly=rain&hourly=snowfall&hourly=precipitation_probability"){
  
  # make the API request and get the result from it (res)
  res <- httr::GET(api)
  
  # obtains data 
  data = jsonlite::fromJSON(rawToChar(res$content))
  return(data)
}


all_weather_data <- function(latitude = 52.37, longitude = 4.89, day_index = 0) {
  if (day_index >6 | day_index < 0){
    stop("The day index can only take values from 0 to 6 (weather data for 7 days is available)")
  }
  
  api <- weather_api(latitude, longitude)
  weather_data <- get_weather_now(api)
  
  # temp
  temperature_day <- round(mean(weather_data$hourly$temperature_2m[(day_index*24 + 8):(day_index*24 + 18)]), 2)
  
  # wind
  wind_speed_day <- round(mean(weather_data$hourly$windspeed_10m[(day_index*24 + 8):(day_index*24 + 18)]), 2)
  
  # shower
  showers_day <- round(mean(weather_data$hourly$showers[(day_index*24 + 8):(day_index*24 + 18)]), 2)
  
  # snow
  snow_day <- round(mean(weather_data$hourly$snowfall[(day_index*24 + 8):(day_index*24 + 18)]), 2)
  
  # rain
  rain_day <- round(mean(weather_data$hourly$rain[(day_index*24 + 8):(day_index*24 + 18)]), 2)
  
  rain_day <- rain_day+showers_day
  
  list('Temp' = temperature_day, 'Wind' = wind_speed_day, 'Snow' = snow_day, 'Rain' = rain_day)
}


#function to obtain the activity based on temperature, rain&shower, snow and wind 

find_activities <- function (temp, rain_shower, snow, wind){
  activities <- read.csv("R/data/activities.csv")
  newdata <- subset(activities,  temp >= temp_low & temp <= temp_high)
  newdata <- subset(newdata,  rain_shower >= rain_low & rain_shower <= rain_high)
  newdata <- subset(newdata,  snow >= snow_low & snow <= snow_high)
  newdata <- subset(newdata,  wind >= wind_low & wind <= wind_high)
  
  # add directory path in front of the picture filenames
  # only do this if we found any picture
  if (nrow(newdata) == 0) {
    return(NULL)
  }
  found_activities <- paste0("R/www/", newdata$picture)
  
  return(found_activities) 
}
 

#function to obtain the clothing based on temperature, rain&shower and snow 

find_clothing <- function (temp, rain_shower, snow){
  clothing <- read.csv("R/data/clothing.csv")
  newdata <- subset(clothing,  temp >= temp_low & temp <= temp_high)
  newdata <- subset(clothing,  rain_shower >= rain_low & rain_shower <= rain_high)
  newdata <- subset(clothing,  snow >= snow_low & snow <= snow_high)
  
  # add directory path in front of the picture filenames
  # only do this if we found any picture
  if (nrow(newdata) == 0) {
    return(NULL)
  }
  found_clothes <- paste0("R/www/", newdata$picture)
  
  return(found_clothes) 
}

################################################################################
### Functions below will be removed later
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
                          