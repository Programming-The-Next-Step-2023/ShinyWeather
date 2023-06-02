.onAttach <- function(libname, pkgname) {
  shiny::addResourcePath("www",
                         system.file("www",
                                     package = "ShinyWeather"))
  shiny::addResourcePath("data",
                         system.file("data",
                                     package = "ShinyWeather"))
}



#.onLoad

#.onUnload <- function (){
# shiny::removeResourcePath("www")
# }