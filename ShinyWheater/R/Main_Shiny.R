source("R/weather.R")

ui <- shiny::fluidPage(
  
  
  shiny::tags$head(
    
    # add a custom message handler that will get temperature data from the server
    shiny::tags$script(shiny::HTML("
        Shiny.addCustomMessageHandler('updateTemperature', function(temp) {
          document.getElementById('tempBar').style.width = temp + '%';
        });
      ")),
    
    # add a custom message handler that will get rain data from the server
    shiny::tags$script(shiny::HTML("
        Shiny.addCustomMessageHandler('updateRain', function(rain) {
          document.getElementById('rainBar').style.width = rain + '%';
        });
      ")),
    
    # add a custom message handler that will get snow data from the server
    shiny::tags$script(shiny::HTML("
        Shiny.addCustomMessageHandler('updateSnow', function(snow) {
          document.getElementById('snowBar').style.width = snow + '%';
        });
      ")),
    
    # add a custom message handler that will get wind data from the server
    shiny::tags$script(shiny::HTML("
        Shiny.addCustomMessageHandler('updateWind', function(wind) {
          document.getElementById('windBar').style.width = wind + '%';
        });
      ")),
    
    # add a custom message handler that will change the Show weather color
    shiny::tags$script(shiny::HTML("
        Shiny.addCustomMessageHandler('changeButtonColor', function(message) {
          $('#go_button').css('background-color', message);
        });
      ")),
    
    # add an orange box around the instructions
    shiny::tags$style(shiny::HTML("
        .instruction_box {
          padding: 15px;
          background-color: #FFA07A;
          color: #000000;
          border-radius: 10px;
        }
      ")),
    
    # add a light yellow box around the descriptions
    shiny::tags$style(shiny::HTML("
        .descriptions_box {
          padding: 5px;
          background-color: #fafadc;
          color: #000000;
          border-radius: 10px;
        }
      "))
  ),
  
  #the title panel contains a fluidrow such that the cloud and sun can be placed next to the title
  shiny::titlePanel(
    shiny::fluidRow(
      shiny::column(2, shiny::img(height = 50, width = 50, src = "https://upload.wikimedia.org/wikipedia/commons/9/95/Cartoon_cloud.svg")),
      shiny::column(8, shiny::h1(shiny::tags$b("Shiny Weather App"), align = "center")), 
      shiny::column(2, shiny::img(height = 50, width = 50, src = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/MeteoSet_Day_%28nbg%29.svg/1024px-MeteoSet_Day_%28nbg%29.svg.png"))
    )
  ),
  
  #first row containing instructions, calendar and map
  shiny::fluidRow(
    shiny::column(6,
                  shiny::tags$div(class = "instruction_box", 
                    shiny::tags$p("Select a ", shiny::tags$b("date"),"from the calendar and a" , shiny::tags$b("point"),"on the map."),
                    shiny::tags$p('Click on', shiny::tags$i("Show Weather"), 'to see what the weather is like.'),
                    shiny::tags$p(shiny::tags$i("Show weather"), 'turns red when a new date or location is chosen.'),
                    shiny::p("Click on it again to see the weather for the new date or location."),
                    shiny::tags$p('Click on',shiny::tags$i("Show Clothes"), 'to see a suitable outfit for this weather.'),
                    shiny::tags$p('Click on', shiny::tags$i("Show Activities"), ' to see what you can do outside on this weather.')
                  ),
                  shiny::br(),
                  
                  #Calendar Input with only 7 days ahead available
                  shiny::dateInput("date", "Select a date:", value = Sys.Date(), min = Sys.Date(), max = Sys.Date()+6),
                  shiny::br(),
                  shiny::radioButtons("day_checkbox", "Select day or evening", choices = list("Day (8 a.m - 6 p.m.)" = "Day", "Evening (6 p.m. - 12 a.m.)" = "Evening"), selected="Day"),
                  shiny::uiOutput("background_color")
    ),
    shiny::column(6,
                  #Output a map of the world
                  leaflet::leafletOutput("map", width = "100%", height = 400)
    )
  ),
  
  #second row containing Show Weather button, weather forecast values and weather progress bars
  shiny::fluidRow(
    shiny::column(6, 
                  
      #Input button to show the weather 
      shiny::actionButton("go_button", "Show Weather", shiny::icon("cloud"), 
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
      shiny::br(),
      shiny::br(),
      
      # Error in case data cannot be obtained
      shiny::textOutput("weather_error"),
    
      shiny::strong("Temperature (°C): "),
      shiny::textOutput("Temperature"),
      shiny::strong("Wind Speed (km/h): "),
      shiny::textOutput("Wind"),
      shiny::strong("Amount of rain (mm): "),
      shiny::textOutput("Rain"),
      shiny::strong("Amount of snow (mm): "),
      shiny::textOutput("Snow")
    ),
    
    shiny::column(6,
      shiny::tags$p(shiny::tags$b("Temperature"), style = "text-align: center;"),
      
      # Progress bar for temperature 
      shiny::div(style = "display: flex; justify-content: space-between; align-items: center; width: 100%;",
          shiny::span("Too cold"),
          shiny::div(id = "tempContainer", 
              style = "background-color: lightgray; width: 250px; height: 20px; margin: 0 10px;", 
              shiny::div(id = "tempBar", 
                  style = "background-color: #d996e9; height: 100%; width: 0;")
          ),
          shiny::span("Too Hot")
      ),
      shiny::br(),
      
      # Progress bar for rain
      shiny::tags$p(shiny::tags$b("Rain"), style = "text-align: center;"),
      shiny::div(style = "display: flex; justify-content: space-between; align-items: center; width: 100%;",
                 shiny::span("No rain "),
                 shiny::div(id = "rainContainer", 
                     style = "background-color: lightgray; width: 250px; height: 20px; margin: 0 10px;", 
                     shiny::div(id = "rainBar", 
                         style = "background-color: #54e4f8; height: 100%; width: 0;")
                 ),
                 shiny::span("Lots of rain")
      ),
      shiny::br(),
      
      # Progress bar for snow
      shiny::tags$p(shiny::tags$b("Snow"), style = "text-align: center;"),
      shiny::div(style = "display: flex; justify-content: space-between; align-items: center; width: 100%;",
                 shiny::span("No snow "),
                 shiny::div(id = "snowContainer", 
                     style = "background-color: lightgray; width: 250px; height: 20px; margin: 0 10px;", 
                     shiny::div(id = "snowBar", 
                         style = "background-color: #e5f7fa; height: 100%; width: 0;")
                 ),
                 shiny::span("Lots of snow")
      ),
      shiny::br(),
      
      # Progress bar for wind
      shiny::tags$p(shiny::tags$b("Wind"), style = "text-align: center;"),
      shiny::div(style = "display: flex; justify-content: space-between; align-items: center; width: 100%;",
                 shiny::span("No wind "),
                 shiny::div(id = "windContainer", 
                     style = "background-color: lightgray; width: 250px; height: 20px; margin: 0 10px;", 
                     shiny::div(id = "windBar", 
                         style = "background-color: #aff6e6; height: 100%; width: 0;")
                 ),
                 shiny::span("Lots of wind")
      )
    )
  ),
  
  #third row containing How to dress? button, Show Activities button and image and descriptions
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
                  shiny::br(),
                  shiny::br(),
                  shiny::conditionalPanel(
                    condition = "input.go_clothes % 2 == 1",
                    shiny::uiOutput("dress_image_UI"),
                    shiny::div(style = "margin-top: -70px"),
                    shiny::uiOutput("clothing_description_UI")
                  )
                  
    ),
    shiny::column(8,
                  #Activities button and images that can be browsed through
                  shiny::actionButton("show", "Show Activities", shiny::icon("search"),
                                      style="color: #fff; background-color: #7bc96f; border-color: #5ca748"),
                  shiny::br(),
                  shiny::br(),
                  shiny::conditionalPanel(
                    condition = "input.show % 2 == 1",
                    shiny::uiOutput("activity_image_UI")
                  ),
                  shiny::div(style = "margin-top: -70px"),
                  shiny::conditionalPanel(
                    condition = "input.show % 2 == 1",
                    shiny::uiOutput("activity_description_UI")
                  ),
                  shiny::conditionalPanel(
                    condition = "input.show % 2 == 1",
                    shiny::div(
                      class = "btn-group",
                      shiny::actionButton("back", "Back"),
                      shiny::actionButton("forward", "Forward"),
                    )
                  ),
      )
    ),
)

# Define server logic required for the app 
server <- function(input, output, session) {

  # set background color depending on whether Day or Evening is Selected
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
    session$sendCustomMessage(type = 'changeButtonColor', message = "#337ab7")
  })
  
  # This outputs the map with default to Amsterdam
  output$map <- leaflet::renderLeaflet({
    leaflet::setView(
      lng = 4.89, lat = 52.37, zoom = 7, leaflet::addTiles(leaflet::leaflet())) # Set the initial view to focus on the Netherlands
  })
  
  #put circle add default location
  leaflet::addCircleMarkers(lng = 4.89, lat = 52.37, radius = 5, color = "green", leaflet::clearMarkers(leaflet::leafletProxy("map")) )
  
  #whether the user clicked "Show Weather" at least once
  #if not, we want to show a special image instead of activities and clothes
  #this variable keeps track wheather user clicked "Show Weather" at least once
  weather_clicked_once <- shiny::reactiveVal(FALSE)
  
  #We start with a reactive value for the weathervalues, which
  #will be changed when we select a location and a day
  weather_data_RT <- shiny::reactiveVal(NULL)
  
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
  
  # We define a list of images, they are generated with the find_activities function
  # Because the input in the find_activities function changes when we set location and time
  # We set images to be a reactive function
  activities <- shiny::reactive({
    
    if (weather_clicked_once() == FALSE) {
      print(weather_clicked_once())
      
      print(weather_clicked_once())
      return(list(images = "R/www/first_click_2.png", descriptions = c("First click on Show Weather")))
    }
    
    result <- NULL
    images <- NULL
    descriptions <- NULL
    
    # set index back to 1
    currentImageIndex(1)
    
    #if the weather data has values 
    if (!is.null(weather_data_RT())) {
      
      #look for activities
      result <- find_activities(temp = weather_data_RT()$Temp, rain_shower = weather_data_RT()$Rain, snow = weather_data_RT()$Snow, wind = weather_data_RT()$Wind, time_of_day=input$day_checkbox)
    }
    
    # check if we found any activities
    # if not, put a default photo
    if (is.null(result)) {
      # images <- c(system.file("R", "www", "first_click_1.png", package = "ShinyWeather"))
      images <- "R/www/bubbles.jpg"
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
           height = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
  })
  
  # this shows the description of activities when one clicks "Show activities"
  output$activity_description_UI <- shiny::renderUI({
    shiny::tags$div(class = "descriptions_box", activity_description())
  })

  #if back is clicked, the current index becomes one image before or stays the same if there is no image before
  shiny::observeEvent(input$back, {
    if (!is.na(currentImageIndex())) {
      currentImageIndex(max(1, currentImageIndex() - 1))
    }
    
    output$image <- shiny::renderImage({
      list(src = activities()$images[currentImageIndex()],
           contentType = 'image/png',
           height = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
    # save activities description to reactive value
    activity_description(activities()$description[currentImageIndex()])
  })
  
  #if forward is clicked, the current index becomes one image after or stays the same if it is the last image
  shiny::observeEvent(input$forward, {
    if (!is.na(currentImageIndex())) {
      currentImageIndex(min(length(activities()$images), currentImageIndex() + 1))
    }
    
    output$image <- shiny::renderImage({
      list(src = activities()$images[currentImageIndex()],
           contentType = 'image/png',
           height = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
    
    # save activities description to reactive value
    activity_description(activities()$description[currentImageIndex()])
  })
  
  #when Go button is pressed, we show weather variables for day and location 
  shiny::observeEvent(input$go_button, {

    weather_clicked_once(TRUE)
    
    # obtain day_index from selected date
    date <- as.Date(input$date)
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
  
  #the images and descriptions for the clothing
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
      # images <- c(system.file("R", "www", "bubbles.jpg", package = "ShinyWeather"))
      images <- "R/www/first_click_2.png"
      descriptions <- c("First click on Show Weather")
    } else {
      images <- result$found_clothes
      descriptions <- result$found_descriptions
    }
    return(list(images = images, descriptions = descriptions))
  })
  
  # this outputs how to dress when clicking "How to dress?" 
  output$dress_image_UI <- shiny::renderUI({
    shiny::imageOutput("dress_image")
    
    output$dress_image <- shiny::renderImage({
      list(src = clothes()$images[1],
           contentType = 'image/jpg',
           height = "80%",
           alt = "This is alternate text")
    }, deleteFile = FALSE)
  })
  
  # this shows the description of the recommended clothes when one clicks 
  # "How to dress?"
  output$clothing_description_UI <- shiny::renderUI({
    tags$div(class = "descriptions_box", clothes()$description[1])
  })

  #send the temperature data to the tempbar
  observe({
    session$sendCustomMessage("updateTemperature", normalize_value(weather_data_RT()$Temp, -15, 40))
  })
  
  #send the rain data to the rainbar
  observe({
    session$sendCustomMessage("updateRain", normalize_value(weather_data_RT()$Rain, 0, 100))
  })
  
  #send the snow data to the snowbar
  observe({
    session$sendCustomMessage("updateSnow", normalize_value(weather_data_RT()$Snow, 0, 100))
  })
  
  #send the wind data to the windbar
  observe({
    session$sendCustomMessage("updateWind", normalize_value(weather_data_RT()$Wind, 0, 60))
  })
}

#normalize a value between 0 and 100 where the value is located between 
#value_min and value_max for correctly showing on the bars
#this is because the bars are ranged between 0 and 100
normalize_value <- function(value, value_min, value_max) {
  
  #make sure value that value is not smaller than value_min and not larger
  #than value-max
  value <- max(value, value_min)
  value <- min(value, value_max)
  
  #first normalize to be between 0 and 1
  value <- (value - value_min) / (value_max - value_min)
  
  #secondly, scale to be between 0 and 100
  value <- value * 100
  
  return(value)
}

# Takes a date object and gives a day_index based on number of days different to current date
get_day_index <- function(date) {
  return(as.integer(date - Sys.Date()))
}
