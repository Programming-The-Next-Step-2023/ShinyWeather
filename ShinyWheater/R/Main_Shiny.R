# library("shiny")
source("R/weather.R")
# library(shinyjs)
#install.packages("shinyjs")
# library(tidyverse)

#library(shinydashboard)


ui <- shiny::fluidPage(
  
  shiny::tags$head(
    shiny::tags$script(shiny::HTML("
      Shiny.addCustomMessageHandler('changeButtonColor', function(message) {
        $('#go_button').css('background-color', message);
      });
    "))),
  
  # Application title
  shiny::titlePanel("Shiny Weather App"),
  
  shiny::fluidRow(
    shiny::column(6,
                  #Calendar Input with only 7 days ahead available
                  shiny::dateInput("date", "Select a date:", value = Sys.Date(), min = Sys.Date(), max = Sys.Date()+6),
                  shiny::br(),
                  #Output which date was selected 
                  shiny::textOutput("selectedDate")
                  
    ),
    shiny::column(6,
                  #Output a map of the world
                  leaflet::leafletOutput("map", width = "100%", height = 400)
                  
    )
  ),
  
  shiny::fluidRow(
    shiny::column(12, 
       #Input button to show the weather 
       shiny::actionButton("go_button", "Show Weather", shiny::icon("cloud"), 
                           style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
      shiny::br(),
      shiny::textOutput("weather_error"),
      shiny::br(),
      shiny::strong("Temperature (°C):"),
      shiny::textOutput("Temperature"),
      shiny::strong("Amount of rain"),
      shiny::textOutput("Rain"),
      shiny::strong("Amount of snow"),
      shiny::textOutput("Snow"),
      shiny::strong("Wind Speed"),
      shiny::textOutput("Wind"),
      shiny::br()
    
    )
  ),

  shiny::fluidRow(
    shiny::column(4,
                  #Input button to show the clothing advice
                  shiny::actionButton("go_clothes", "How to dress?", shiny::icon("star"), 
                                      style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                  shiny::conditionalPanel(
                    condition = "input.go_clothes % 2 == 1",
                    shiny::uiOutput("dress_image_UI")
                  )
                  
    ),
    shiny::column(4,
                  #Activities button and images that can be browsed through
                  shiny::actionButton("show", "Show Activities", shiny::icon("search"),
                                      style="color: #fff; background-color: #7bc96f; border-color: #5ca748"),
                  shiny::conditionalPanel(
                      condition = "input.show % 2 == 1",
                      shiny::div(
                        class = "btn-group",
                        shiny::actionButton("back", "Back"),
                        shiny::actionButton("forward", "Forward"),
                      )
                  ),
                  shiny::br(),
                  shiny::br(),
                  shiny::conditionalPanel(
                    condition = "input.show % 2 == 1",
                    shiny::uiOutput("activity_image_UI")
                  )
    ),
    shiny::column(4,
                  shiny::textOutput("hi")
           
    )
  ),

)

# 
#   # Sidebar with calendar, weather values and clothing advice
#   shiny::sidebarLayout(
#     
#     shiny::sidebarPanel(
#   
#       #Calendar Input with only 7 days ahead available
#       shiny::dateInput("date", "Select a date:", value = Sys.Date(), min = Sys.Date(), max = Sys.Date()+6),
#       shiny::br(),
#       
#       #Input button to show the weather 
#       shiny::actionButton("go_button", "Show Weather", shiny::icon("cloud"), 
#                           style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
#       shiny::br(),
#       shiny::strong("Temperature (°C):"),
#       shiny::textOutput("Temperature"),
#       shiny::strong("Amount of rain"),
#       shiny::textOutput("Rain"),
#       shiny::strong("Amount of snow"),
#       shiny::textOutput("Snow"),
#       shiny::strong("Wind Speed"),
#       shiny::textOutput("Wind"),
#       shiny::br(),
#       
#       #Input button to show the clothing advice
#       shiny::actionButton("go_clothes", "How to dress?", shiny::icon("star"), 
#                           style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
#       shiny::br(),
#       shiny::br(),
#       shiny::imageOutput("dress")
#       
#     ),
#     
#     # Show a map and a collection of activities
#     shiny::mainPanel(
#       
#       #Output which date was selected 
#       shiny::textOutput("selectedDate"),
#       
#       #Output a map of the world
#       leaflet::leafletOutput("map", width = "100%", height = 400),
#       shiny::br(),
#       
#       #Activities button and images that can be browsed through
#       shiny::actionButton("show", "Show Activities", shiny::icon("search"),
#                           style="color: #fff; background-color: #7bc96f; border-color: #5ca748"),
#       shiny::conditionalPanel(
#         condition = "input.show % 2 == 1",
#         shiny::div(
#           class = "btn-group",
#           shiny::actionButton("back", "Back"),
#           shiny::actionButton("forward", "Forward"),
#       ),
#       shiny::textOutput("hi"),
#       shiny::br(),
#       shiny::br(),
#       shiny::imageOutput("image")
#       
#         
#       )
#     )
#   )
# )

# Define server logic required for the app 

server <- function(input, output, session) {
  
  shiny::observe({
    input$date
    session$sendCustomMessage(type = 'changeButtonColor', message = "red")
  })
  
  shiny::observe({
    input$map_click
    session$sendCustomMessage(type = 'changeButtonColor', message = "red")
  })
  
  shiny::observe({
    input$go_button
    session$sendCustomMessage(type = 'changeButtonColor', message = "blue")
  })
  
  #We start with a reactive value for the weathervalues, which
  # will be changed when we select a location and a day
  weather_data_RT <- reactiveVal(NULL)
  
  #This prints the latitude and longitude of where we clicked, it is a check 
  shiny::observeEvent(input$map_click, {
    click <- input$map_click
    lat <- click$lat
    lng <- click$lng
    leaflet::addCircleMarkers(lng = lng, lat = lat, radius = 5, color = "green", leaflet::clearMarkers(leaflet::leafletProxy("map")) )
    # print(input$map_click)
  })
  
  #This outputs the map with default to Amsterdam
  output$map <- leaflet::renderLeaflet({
      leaflet::setView(lng = 4.89, lat = 52.37, zoom = 7, leaflet::addTiles(leaflet::leaflet())) # Set the initial view to focus on the Netherlands
  })
  
  #This outputs a text saying which date was selected 
  output$selectedDate <- shiny::renderText({
    
    # can do some logic with the date here...
    # print(input$date)
    # print(input$date + 1)
    
    paste("You have selected:", input$date)
    
  })
  
  #the Images vector will be indexed according to the cliks on back and foward buttons
  #we start with a currentImageIndex on the first image
  currentImageIndex <- shiny::reactiveVal(1)
  
  # We define a list of images, they are generated with the find_activities function
  # Because the input in the find_activities function changes when we set location and time
  # We set images to be a reactive function
  images <- shiny::reactive({
    
    activities <- NULL
    
    # set index back to 1
    currentImageIndex(1)
    
    #if the weather data has values 
    if (!is.null(weather_data_RT())) {
      
      #look for activities
      activities <- find_activities(temp = weather_data_RT()$Temp, rain_shower = weather_data_RT()$Rain, snow = weather_data_RT()$Snow, wind = weather_data_RT()$Wind)
    }
    
    # check if we found any activities
    # if not, put a default photo
    if (is.null(activities)) {
      activities <- c("R/www/bubbles.jpg")
    }
    return(activities)
  })
  
  # this shows the activity images when one clicks "Show activities"
  output$activity_image_UI <- shiny::renderUI({
    shiny::imageOutput("activity_image")
    
    output$activity_image <- shiny::renderImage({
      list(src = images()[currentImageIndex()],
           contentType = 'image/jpg',
           width = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
  })

  #if back is clicked, the current index becomes one image before or stays the same if there is no image before
  shiny::observeEvent(input$back, {
    if (!is.na(currentImageIndex())) {
      currentImageIndex(max(1, currentImageIndex() - 1))
    }
    
    output$image <- shiny::renderImage({
      list(src = images()[currentImageIndex()],
           contentType = 'image/png',
           width = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
  })
  
  #if forward is clicked, the current index becomes one image after or stays the same if it is the last image
  shiny::observeEvent(input$forward, {
    if (!is.na(currentImageIndex())) {
      currentImageIndex(min(length(images()), currentImageIndex() + 1))
    }
    
    output$image <- shiny::renderImage({
      list(src = images()[currentImageIndex()],
           contentType = 'image/png',
           width = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
  })

  #when Go button is pressed, we show weather variables for day and location 
  shiny::observeEvent(input$go_button, {
    
    # obtain day_index from selected date
    date <- as.Date(input$date)
    # print(date)
    # print(input$map_click)
    day_index <- get_day_index(date)
    
    # obtain longitude and latitude from map_click
    # if user didn't click on the map, use a default location
    if (is.null(input$map_click)) {
      longitude <- 4.89
      latitude <- 52.37
    } else {
      longitude <- input$map_click$lng
      latitude <- input$map_click$lat
    }
    
    # update weather and set reactive value
    weather_data <- all_weather_data(longitude = longitude, latitude = latitude, day_index = day_index)
    weather_data_RT(weather_data)
    
    output$Temperature <- shiny::renderText({weather_data$Temp})
    output$Rain <- shiny::renderText({weather_data$Rain})
    output$Snow <- shiny::renderText({weather_data$Snow})
    output$Wind <- shiny::renderText({weather_data$Wind})
    
    # check if weather_data returned any errors
    # if so, write message to screen saying retrieval was not successfull
    if (weather_data$Error) {
      output$weather_error <- shiny::renderText({"Error retrieving weather"})
    }
    
  })
  
  #the images for the clothing
  clothes_images <- shiny::reactive({
    
    clothes <- NULL

    #if the weather data has values 
    if (!is.null(weather_data_RT())) {
      
      #look for activities
      clothes <- find_clothing(temp = weather_data_RT()$Temp, rain_shower = weather_data_RT()$Rain, snow = weather_data_RT()$Snow)
    }
    
    # check if we found any activities
    # if not, put a default photo
    if (is.null(clothes)) {
      clothes <- c("R/www/bubbles.jpg")
    }
    
    return(clothes)
  })
  
  # this outputs how to dress when clicking "How to dress?" 
  output$dress_image_UI <- shiny::renderUI({
    shiny::imageOutput("dress_image")
    
    output$dress_image <- shiny::renderImage({
      list(src = clothes_images()[1],
           contentType = 'image/jpg',
           width = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
  })

}

# Takes a date object and gives a day_index based on number of days different to current date
get_day_index <- function(date) {
  return(as.integer(date - Sys.Date()))
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

