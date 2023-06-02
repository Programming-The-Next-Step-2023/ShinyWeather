source("R/Main_shiny.R")
#' runShinyWeather
#'
#' This is the function that can be run by the user to open the ShinyWeather App.
#' For the documentation of the app, use '?ShinyWeather'
#'
#' @export
#'
#' @examples runShinyWeather()
#'
runShinyWeather <- function() {
  shiny::shinyApp(ui = ui, server = server)
}
runShinyWeather()

