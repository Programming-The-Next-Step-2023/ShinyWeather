#' A Child-Friendly Weather App 
#' 
#' 
#' @section Shiny App:
#' The \emph{ShinyWeather} app can be run using the runShinyWeather() function.
#' 
#' This App is meant to be used by parents together with children. It helps explain the weather to children in a simple way. 
#' 
#' @section The display contains:
#'  * a \emph{map of the world centered on the Netherlands}
#'  
#'  * a \emph{calendar field}
#'  
#'  * \emph{values for temperature, rain, snow and wind}
#'  
#'  * \emph{progress bars showing temperature, rain, snow and wind}
#'  
#'  * a \emph{"Show Weather" button}
#'  
#'  * a \emph{"Show Activity" button}
#'  
#'  * an \emph{image placeholder for activities}
#'  
#'  * an \emph{image placeholder for clothes}
#' 
#' @section Usage:
#' First choose a location by clicking on the map and a date by selecting one in the calendar field.
#' It is possible to check the weather forecast for up to seven days including the current day.  
#' 
#' By clicking "Show Weather" a field containing weather variables will appear.
#' The weather variables displayed are: \emph{temperature},  \emph{rain},\emph{snow} and \emph{wind speed}.
#' 
#' By clicking "Show Activities" a field containing images of activities will be displayed.
#' A text description will be shown under each image.
#' Browse through the activities using the "Back" and "Forward" buttons.
#' The activities displayed are based on the weather variables. They show what kind of activities can be done based on the weather conditions of the chosen day.
#' 
#'  @section Common problem:
#' The app uses an API to obtain the weather data. It will not work without an internet connection.
#' 
#' @section Credits:
#' 
#' The weather forecast is obtained from: https://open-meteo.com/
#' The pictures used in the app are from: https://unsplash.com/ and https://www.pexels.com
#' Links to all activities pictures can be found by running ShinyWheather::activities_day$link and ShinyWheather::activities_night$link
#' Links to all clothes pictures can be found by running ShinyWheather::clothes$link
#' 
#' The following websites were used to determine the thresholds for each weather variable:
#' https://varendoejesamen.nl/kenniscentrum/artikel/windkracht-en-de-schaal-van-beaufort-hoe-zit-het-precies
#' https://windy.app/blog/how-do-we-measure-precipitation.html
#' https://charts.ecmwf.int/products/medium-snowfall?base_time=202306020000&projection=opencharts_europe&valid_time=202306020600
#' 
#' @section Contact:
#' 
#' For information about the ShinyWeather App, contact `magda.matetovici@student.uva.nl`
#' 
#' @docType package
#'
#' @name ShinyWeather
#'
NULL