
# Tests for weather_api()
test_that("the api string from weather_api() is correctly outputted", {
  my_api = weather_api(latitude= 51.6, longitude = 3.2)
  expected_api = "https://api.open-meteo.com/v1/forecast?latitude=51.6&longitude=3.2&hourly=temperature_2m&current_weather=true&hourly=windspeed_10m&hourly=rain&hourly=snowfall&hourly=precipitation&hourly=showers"
  
  expect_equal(my_api, expected_api)
})

test_that("the weather_api() gives error if input is out of bounds", {
  expect_error(weather_api(latitude= -200, longitude = 3.2))
  expect_error(weather_api(latitude= 200, longitude = 3.2))
  expect_error(weather_api(latitude= 56, longitude = 290))
  expect_error(weather_api(latitude= 67, longitude = -290))
})


# Tests for all_weather_data()
test_that("the all_weather_data() gives error if day_index is out of bounds", {
  expect_error(all_weather_data(day_index = -1))
  expect_error(all_weather_data(day_index = 8))
})

test_that("the all_weather_data() gives error if time_of_day is incorrect", {
  
  # day and night should be written with capital first letter
  expect_error(all_weather_data(time_of_day = "day"))
  expect_error(all_weather_data(time_of_day = "night"))
  expect_error(all_weather_data(time_of_day = "wrong_input"))
})

test_that("the all_weather_data() gives the correct list of weather variables", {
  weather_data <- all_weather_data(day_index = 3)
  output_variables <- names(weather_data)
  
  expected_variables = c('Temp', 'Wind','Snow', 'Rain', 'Error')
  
  expect_true(all(expected_variables %in% output_variables))
})


# Tests for find_clothing()
test_that("the find_clothing() gives the correct list of variables", {
  clothes <- find_clothing(10, 10, 0)
  output_variables <- names(clothes)
  
  expected_variables = c('found_clothes', 'found_descriptions')
  
  expect_true(all(expected_variables %in% output_variables))
})

test_that("the find_clothing() gives NULL if no clothes are found", {
  clothes <- find_clothing(-100, -100, -100)
  
  expect_null(clothes)
})


# Tests for find_activities()
test_that("the find_clothing() gives the correct list of variables", {
  activities <- find_activities(10, 0, 0, 0)
  output_variables <- names(activities)
  
  expected_variables = c('found_activities', 'found_descriptions')
  
  expect_true(all(expected_variables %in% output_variables))
})

test_that("the find_activities() gives NULL if no activities are found", {
  activities <- find_activities(-100, -100, -100, -100)
  
  expect_null(activities)
})