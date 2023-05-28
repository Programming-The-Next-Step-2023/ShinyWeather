source("R/weather.R")

ui <- shiny::fluidPage(
  
  # shiny::tags$style(shiny::HTML(
  #   "body { background-color: yellow }"
  # )),
  
  shiny::tags$head(
    shiny::tags$script(shiny::HTML("
      Shiny.addCustomMessageHandler('changeButtonColor', function(message) {
        $('#go_button').css('background-color', message);
      });
    ")),
    shiny::tags$style(shiny::HTML("
      .instruction_box {
        padding: 15px;
        background-color: #FFA07A;
        color: #000000;
      }
    ")),
    shiny::tags$style(shiny::HTML("
      .descriptions_box {
        padding: 15px;
        background-color: #FAA07A;
        color: #000000;
      }
    "))
  ),
  
  # Application title
  shiny::titlePanel("Shiny Weather App"),
  
  shiny::fluidRow(
    shiny::column(6,
                  shiny::tags$div(class = "instruction_box", 
                    shiny::p("Select a date from the calendar and a point on the map"),
                    shiny::p("Click on Show Weather to see what the weather is like"),
                    shiny::p("Show weather turns red when a new date or location is chosen"),
                    shiny::p("Click on it again to see the weather for the new date or location"),
                    shiny::p("Click on Show Clothes to see a suitable outfit for this weather"),
                    shiny::p("Click on Show Activities to see what you can do outside on this weather")
                  ),
                  shiny::br(),
                  #Calendar Input with only 7 days ahead available
                  shiny::dateInput("date", "Select a date:", value = Sys.Date(), min = Sys.Date(), max = Sys.Date()+6),
                  shiny::br(),
                  #Output which date was selected 
                  shiny::textOutput("selectedDate"),
                  shiny::radioButtons("day_checkbox", "Select day or evening", choices = c("Day", "Evening"), selected="Day"),
                  shiny::uiOutput("background_color")
    ),
    shiny::column(6,
                  #Output a map of the world
                  leaflet::leafletOutput("map", width = "100%", height = 400)
    )
  ),
  
  shiny::fluidRow(
    shiny::column(4, 
       #Input button to show the weather 
       shiny::actionButton("go_button", "Show Weather", shiny::icon("cloud"), 
                           style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
      shiny::br(),
      shiny::textOutput("weather_error"),
    ),
    shiny::column(4,
                  shiny::strong("Temperature (°C): "),
                  shiny::textOutput("Temperature"),
                  shiny::strong("Wind Speed: "),
                  shiny::textOutput("Wind")
    ),
    shiny::column(4,
                  shiny::strong("Amount of rain: "),
                  shiny::textOutput("Rain"),
                  shiny::strong("Amount of snow: "),
                  shiny::textOutput("Snow")
    )
  ),
  
  shiny::fluidRow(
    shiny::column(12,
                  shiny::br(),
    )
  ),
  
  shiny::fluidRow(
    shiny::column(4,
                  #Input button to show the clothing advice
                  shiny::actionButton("go_clothes", "How to dress?", shiny::icon("star"), 
                                      style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                  shiny::conditionalPanel(
                    condition = "input.go_clothes % 2 == 1",
                    shiny::br(),
                    shiny::uiOutput("clothing_description_UI"),
                    shiny::br(),
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
                  shiny::conditionalPanel(
                    condition = "input.show % 2 == 1",
                    shiny::uiOutput("activity_description_UI")
                  )
    )
  ),
)

# Define server logic required for the app 
server <- function(input, output, session) {
  
  # set background color
  output$background_color <- shiny::renderUI({
    selected_period <- input$day_checkbox
    if (selected_period == "Day") {
      color <- "#f7f7a1"
    } else {
      color <- "#819cb1"
    }
    shiny::tags$style(shiny::HTML(
      paste0("body {background-color: ", color, ";}")
    ))
  })
  
  # change button colors when they have been clicked
  shiny::observe({
    input$date
    session$sendCustomMessage(type = 'changeButtonColor', message = "red")
  })
  
  shiny::observe({
    input$map_click
    session$sendCustomMessage(type = 'changeButtonColor', message = "red")
  })
  
  shiny::observe({
    input$day_checkbox
    session$sendCustomMessage(type = 'changeButtonColor', message = "red")
  })
  
  shiny::observe({
    input$go_button
    session$sendCustomMessage(type = 'changeButtonColor', message = "blue")
  })
  
  # This outputs the map with default to Amsterdam
  output$map <- leaflet::renderLeaflet({
    leaflet::setView(
      lng = 4.89, lat = 52.37, zoom = 7, leaflet::addTiles(leaflet::leaflet())) # Set the initial view to focus on the Netherlands
  })
  leaflet::addCircleMarkers(lng = 4.89, lat = 52.37, radius = 5, color = "green", leaflet::clearMarkers(leaflet::leafletProxy("map")) )
  
  #We start with a reactive value for the weathervalues, which
  # will be changed when we select a location and a day
  weather_data_RT <- reactiveVal(NULL)
  
  #the Images vector will be indexed according to the clicks on back and forward buttons
  #we start with a currentImageIndex on the first image
  currentImageIndex <- shiny::reactiveVal(1)
  
  # this contains the description of the current activity
  activity_description <- shiny::reactiveVal("No description found")
  
  #This prints the latitude and longitude of where we clicked, it is a check 
  shiny::observeEvent(input$map_click, {
    click <- input$map_click
    lat <- click$lat
    lng <- click$lng
    leaflet::addCircleMarkers(lng = lng, lat = lat, radius = 5, color = "green", leaflet::clearMarkers(leaflet::leafletProxy("map")) )
  })
  
  #This outputs a text saying which date was selected 
  output$selectedDate <- shiny::renderText({
    
    # can do some logic with the date here...
    # print(input$date)
    # print(input$date + 1)
    
    paste("You have selected:", input$date)
    
  })
  
  # We define a list of images, they are generated with the find_activities function
  # Because the input in the find_activities function changes when we set location and time
  # We set images to be a reactive function
  activities <- shiny::reactive({
    
    result <- NULL
    images <- NULL
    descriptions <- NULL
    
    # set index back to 1
    currentImageIndex(1)
    
    #if the weather data has values 
    if (!is.null(weather_data_RT())) {
      
      #look for activities
      result <- find_activities(temp = weather_data_RT()$Temp, rain_shower = weather_data_RT()$Rain, snow = weather_data_RT()$Snow, wind = weather_data_RT()$Wind)
    }
    
    # check if we found any activities
    # if not, put a default photo
    if (is.null(result)) {
      images <- c(system.file("R", "www", "bubbles.jpg", package = "ShinyWeather"))
      descriptions <- c("No activities found")
    } else {
      images <- result$found_activities
      descriptions <- result$found_descriptions
    }
    return(list(images = images, descriptions = descriptions))
  })
  
  # this shows the activity images when one clicks "Show activities"
  output$activity_image_UI <- shiny::renderUI({
    
    # save activities description to reactive value
    activity_description(activities()$description[currentImageIndex()])
    
    shiny::imageOutput("activity_image")
    
    output$activity_image <- shiny::renderImage({
      list(src = activities()$images[currentImageIndex()],
           contentType = 'image/jpg',
           width = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
  })
  
  # this shows the description of activities when one clicks "Show activities"
  output$activity_description_UI <- shiny::renderUI({
    shiny::tags$div(class = "descriptions_box", activity_description())
    # shiny::textOutput("activity_description")
    # 
    # output$activity_description <- shiny::renderText({
    #   activities()$descriptions[currentImageIndex()]
    # })
    
  })

  #if back is clicked, the current index becomes one image before or stays the same if there is no image before
  shiny::observeEvent(input$back, {
    if (!is.na(currentImageIndex())) {
      currentImageIndex(max(1, currentImageIndex() - 1))
    }
    
    output$image <- shiny::renderImage({
      list(src = activities()$images[currentImageIndex()],
           contentType = 'image/png',
           width = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
    # save activities description to reactive value
    activity_description(activities()$description[currentImageIndex()])
    
    # output$activity_description <- shiny::renderText({
    #   activities()$descriptions[currentImageIndex()]
    # })
  })
  
  #if forward is clicked, the current index becomes one image after or stays the same if it is the last image
  shiny::observeEvent(input$forward, {
    if (!is.na(currentImageIndex())) {
      currentImageIndex(min(length(activities()$images), currentImageIndex() + 1))
    }
    
    output$image <- shiny::renderImage({
      list(src = activities()$images[currentImageIndex()],
           contentType = 'image/png',
           width = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
    # save activities description to reactive value
    activity_description(activities()$description[currentImageIndex()])
    
    # output$activity_description <- shiny::renderText({
    #   activities()$descriptions[currentImageIndex()]
    # })
    
  })
  
  shiny::observeEvent(input$day_checkbox, {
    print(input$day_checkbox)
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
    weather_data <- all_weather_data(longitude = longitude, latitude = latitude, day_index = day_index, time_of_day=input$day_checkbox)
    weather_data_RT(weather_data)
    
    output$Temperature <- shiny::renderText({weather_data$Temp})
    output$Rain <- shiny::renderText({weather_data$Rain})
    output$Snow <- shiny::renderText({weather_data$Snow})
    output$Wind <- shiny::renderText({weather_data$Wind})
    
    # check if weather_data returned any errors
    # if so, write message to screen saying retrieval was not successfull
    if (weather_data$Error) {
      output$weather_error <- shiny::renderText({"Error retrieving weather. \nMaybe check your internet connection..."})
    }
    
  })
  
  #the images for the clothing
  clothes <- shiny::reactive({
    
    result <- NULL
    images <- NULL
    descriptions <- NULL

    #if the weather data has values 
    if (!is.null(weather_data_RT())) {
      
      #look for clothing advice
      result <- find_clothing(temp = weather_data_RT()$Temp, rain_shower = weather_data_RT()$Rain, snow = weather_data_RT()$Snow)
    }
    
    # check if we found any activities
    # if not, put a default photo
    if (is.null(result)) {
      images <- c(system.file("R", "www", "bubbles.jpg", package = "ShinyWeather"))
      descriptions <- c("No clothes found")
    } else {
      images <- result$found_clothes
      descriptions <- result$found_descriptions
    }
    return(list(images = images, descriptions = descriptions))
    
    # 
    # # check if we found any activities
    # # if not, put a default photo
    # if (is.null(clothes)) {
    #   clothes <- c("R/www/bubbles.jpg")
    # }
    # 
    # return(clothes)
  })
  
  # this outputs how to dress when clicking "How to dress?" 
  output$dress_image_UI <- shiny::renderUI({
    shiny::imageOutput("dress_image")
    
    output$dress_image <- shiny::renderImage({
      list(src = clothes()$images[1],
           contentType = 'image/jpg',
           width = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
  })
  
  output$clothing_description_UI <- shiny::renderUI({
    
    tags$div(class = "descriptions_box", clothes()$description[1])
    # shiny::textOutput("clothing_description")
    # 
    # output$clothing_description <- shiny::renderText({
    #   
    #   print(clothes()$description[1])
    #   clothes()$description[1]
    #   # shiny::tags$div(class = "descriptions_box",
    #   #                 clothes()$description[1]
    #   # )
    #   
    # })
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

