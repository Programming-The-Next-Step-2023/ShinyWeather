# Functions for the Shiny Weather App, mainly concerning with the weather API
# and the activities and clothes data files

#make a custom API string
weather_api <- function (latitude = 52.37, longitude = 4.89){
  
  #check if latitude and longitude fall within correct limits
  if (latitude >90 | latitude < -90){
    stop("Latitude inputed is outside the range [-90,90]")
  }
  if (longitude >180 | longitude < -180){
    stop("Longitude inputed is outside the range [-180,180]")
  }
  
  #the root gives us where to take the data from 
  root = "https://api.open-meteo.com/v1/forecast?"
  
  #the measures are the variables we want to retrieve
  measures = "&hourly=temperature_2m&current_weather=true&hourly=windspeed_10m&hourly=rain&hourly=snowfall&hourly=precipitation&hourly=showers"
  
  #this adds the root and measures together with the inputed latitude and longitude
  my_api = paste0(root,"latitude=",latitude,"&longitude=",longitude, measures)
  return(my_api)
}


#function to get hourly weather for the next 7 days starting with current day
get_weather_now <- function(api = "https://api.open-meteo.com/v1/forecast?latitude=52.37&longitude=4.89&hourly=temperature_2m&current_weather=true&hourly=windspeed_10m&hourly=rain&hourly=snowfall&hourly=precipitation_probability"){
  
  # make the API request and get the result from it (res)
  # if the request is unsuccesfull (for example, when there is no internet connection),
  # than catch the error so that app doesn't crash
  data <- tryCatch({
    
    # res contains the data in json format 
    res <- httr::GET(api)
    
    # extract the data to a dataframe
    data_json <- jsonlite::fromJSON(rawToChar(res$content))
  }, error = function(e) {
    return(NULL)
  })
  
  # obtains data 
  return(data)
}


#function to get the weather measures for a specific location, date and time of day
all_weather_data <- function(latitude = 52.37, longitude = 4.89, day_index = 0, time_of_day = "Day") {
  
  #check if data index is not between 0 and 6, send error message
  if (day_index > 6 | day_index < 0){
    stop("The day index can only take values from 0 to 6 (weather data for 7 days is available)")
  }
  
  #check if time of the day is not day or evening, send error message
  if (time_of_day != "Day" & time_of_day != "Evening"){
    stop("time_of_day should be either Day or Evening")
  }
  
  # these give the hour ranges for Day and Evening
  day_time_low <- 8
  day_time_high <- 18
  evening_time_low <- 18
  evening_time_high <- 24
  
  # selected indices based on Day or Night
  if (time_of_day == "Day") {
    ind_low <- day_time_low
    ind_high <- day_time_high
  } else {
    ind_low <- evening_time_low
    ind_high <- evening_time_high
  }
  
  api <- weather_api(latitude, longitude)
  weather_data <- get_weather_now(api)
  
  # check if getting weather data was successfull
  # if not, return error message and zero for all data fields
  if (is.null(weather_data)) {
    return(list('Temp' = "-", 'Wind' = "-", 'Snow' = "-", 'Rain' = "-", "Error" = TRUE))
  }
  
  # temperature_day is the mean temperature of all hours for day or evening
  temperature_day <- round(mean(weather_data$hourly$temperature_2m[(day_index*24 + ind_low):(day_index*24 + ind_high)]), 2)
  
  # wind is the mean wind of all hours for day or evening
  wind_speed_day <- round(mean(weather_data$hourly$windspeed_10m[(day_index*24 + ind_low):(day_index*24 + ind_high)]), 2)
  
  # shower is the mean showers of all hours for day or evening
  showers_day <- round(sum(weather_data$hourly$showers[(day_index*24 + ind_low):(day_index*24 + ind_high)]), 2)
  
  # snow is the mean snow of all hours for day or evening
  snow_day <- round(sum(weather_data$hourly$snowfall[(day_index*24 + ind_low):(day_index*24 + ind_high)]), 2)
  
  # rain is the mean rain of all hours for day or evening
  rain_day <- round(sum(weather_data$hourly$rain[(day_index*24 + ind_low):(day_index*24 + ind_high)]), 2)
  
  # total precipitation except snow (we treat rain and shower as the same)
  rain_day <- rain_day+showers_day
  
  list('Temp' = temperature_day, 'Wind' = wind_speed_day, 'Snow' = snow_day, 'Rain' = rain_day, "Error" = FALSE)
}


# function to obtain the activity based on temperature, rain&shower, snow and wind 
find_activities <- function (temp, rain_shower, snow, wind, time_of_day = "Day"){

  #check if Day or Evening was selected 
   if (time_of_day != "Day" & time_of_day != "Evening"){
    stop("time_of_day should be either Day or Evening")
  }
  
  #Load the correct csv file based on Day or Evening
  if (time_of_day == "Day") {
    # activities <- read.csv("R/data/activities_day.csv")
    activities <- read.csv(system.file("R", "data", "activities_day.csv", package = "ShinyWeather"))
  } else {
    # activities <- read.csv("R/data/activities_evening.csv")
    activities <- read.csv(system.file("R", "data", "activities_evening.csv", package = "ShinyWeather"))
  }
  
  # for each variable, keep only the rows (activities) where the value of the variable
  # falls inside the two thresholds - that is why we subset each time
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
  found_descriptions <- newdata$description
  
  return(list(found_activities = found_activities, found_descriptions = found_descriptions))
}
 

#function to obtain the clothing based on temperature, rain&shower and snow 
find_clothing <- function (temp, rain_shower, snow){
  
  #load csv file containing lower and upper threshold of the three variables for each clothing style
  # print(system.file("R", "data", "clothing.csv", package = "ShinyWeather"))
  # clothing <- read.csv(system.file("R", "data", "clothing.csv", package = "ShinyWeather"))
  
  clothing <- read.csv(system.file("R", "data", "clothing.csv", package = "ShinyWeather"))
  # clothing <- read.csv("R/data/clothing.csv")
  
  # for each variable, keep only the rows (activities) where the value of the variable
  # falls inside the two thresholds - that is why we subset each time
  newdata <- subset(clothing,  temp >= temp_low & temp <= temp_high)
  newdata <- subset(newdata,  rain_shower >= rain_low & rain_shower <= rain_high)
  newdata <- subset(newdata,  snow >= snow_low & snow <= snow_high)
  
  # add directory path in front of the picture filenames
  # only do this if we found any picture
  if (nrow(newdata) == 0) {
    return(NULL)
  }
  found_clothes <- paste0("R/www/", newdata$picture)
  found_descriptions <- newdata$description
  
  return(list(found_clothes = found_clothes, found_descriptions = found_descriptions)) 
}
