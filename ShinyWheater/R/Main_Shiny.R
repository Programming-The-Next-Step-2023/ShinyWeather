# library("shiny")
source("R/weather.R")
# library(shinyjs)
#install.packages("shinyjs")
# library(tidyverse)

#library(shinydashboard)
# Define UI for application that draws a histogram
ui <- shiny::fluidPage(
  
  # Application title
  shiny::titlePanel("Shiny Weather App"),
  
  # Sidebar with a slider input for number of bins 
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::dateInput("date", "Select a date:", value = Sys.Date(), min = Sys.Date(), max = Sys.Date()+6),
      shiny::actionButton("go_button", "Show Weather"),
      shiny::br(),
      shiny::strong("Temperature (°C):"),
      shiny::textOutput("Temperature"),
      shiny::strong("Amount of rain"),
      shiny::textOutput("Rain"),
      shiny::strong("Amount of snow"),
      shiny::textOutput("Snow"),
      shiny::strong("Wind Speed"),
      shiny::textOutput("Wind"),
      
    ),
    
    # Show a plot of the generated distribution
    shiny::mainPanel(
      shiny::textOutput("selectedDate"),
      leaflet::leafletOutput("map", width = "100%", height = 400),
      shiny::br(),
      shiny::actionButton("show", "Show Activities"),
      shiny::imageOutput("image"),
      shiny::div(
        class = "btn-group",
        shiny::actionButton("back", "Back"),
        shiny::actionButton("forward", "Forward"),
        
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  shiny::observeEvent(input$map_click, {
    print(input$map_click)
  })
  
  #this outputs the map
  output$map <- leaflet::renderLeaflet({
      leaflet::setView(lng = 4.89, lat = 52.37, zoom = 7, leaflet::addTiles(leaflet::leaflet())) # Set the initial view to focus on the Netherlands
  })
  
  #this outputs a test saying which date was selected 
  output$selectedDate <- shiny::renderText({
    
    # can do some logic with the date here...
    print(input$date)
    print(input$date + 1)
    
    paste("You have selected:", input$date)
    
  })
  
  #this shows the image when one clicks Show image
  shiny::observeEvent(input$show, {
    output$image <- shiny::renderImage({
      list(src = "R/www/sun.png",
           contentType = 'image/png',
           width = 400,
           height = 400,
           alt = "This is alternate text",
           deleteFile = FALSE)
    })
  })
  
  #here I store all the images with activities to do
  images <- c(
    "R/www/sun.png",
    "R/www/cloud.png"
  )
  
  #the Images vector will be indexed according to the cliks on back and foward buttons
  #we start with a currentImageIndex on the first image
  currentImageIndex <- shiny::reactiveVal(1)
  
  #if back is clicked, the current index becomes one image before or stays the same if there is no image before
  shiny::observeEvent(input$back, {
    if (!is.na(currentImageIndex())) {
      currentImageIndex(max(1, currentImageIndex() - 1))
    }
    
    output$image <- shiny::renderImage({
      list(src = images[currentImageIndex()],
           contentType = 'image/png',
           width = 400,
           height = 400,
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
  })
  
  #if forward is clicked, the current index becomes one image after or stays the same if it is the last image
  shiny::observeEvent(input$forward, {
    if (!is.na(currentImageIndex())) {
      currentImageIndex(min(length(images), currentImageIndex() + 1))
    }
    
    output$image <- shiny::renderImage({
      list(src = images[currentImageIndex()],
           contentType = 'image/png',
           width = 400,
           height = 400,
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
  })

  #when Go button is pressed, we show weather variables for day and location (day and location to be implemented)
  shiny::observeEvent(input$go_button, {
    
    date <-as.Date(input$date, format = "%Y-%m-%d")
    weather_data <- all_weather_data(day_index = 3)
    output$Temperature <- shiny::renderText({weather_data$Temp})
    output$Rain <- shiny::renderText({weather_data$Rain})
    output$Snow <- shiny::renderText({weather_data$Snow})
    output$Wind <- shiny::renderText({weather_data$Wind})
  })

}

#' runShinyWeather
#' 
#' This is the function that can be run by the user to open the ShinyWeather App
#' 
#' @export 
#'
#' @examples runShinyWeather()
#' 
runShinyWeather <- function() {
  shiny::shinyApp(ui = ui, server = server)
}
runShinyWeather()

