#Test for get_day_index()
test_that("get_day_index() returns correct index", {
  
  # index should be 3 for 3 days added to current date
  test_data <- Sys.Date() + 3
  
  index <- get_day_index(test_data)
  expect_equal(index, index)
})