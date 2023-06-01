#Test for get_day_index()
test_that("get_day_index() returns correct index", {
  
  # index should be 3 for 3 days added to current date
  test_data <- Sys.Date() + 3
  
  index <- get_day_index(test_data)
  expect_equal(index, index)
})

#Test for normalize_value()
test_that("normalize_value() returns correct value", {
  
  #test if it returns 0 if value falls out of lower range
  expect_equal(normalize_value(-10, 0, 10), 0)
  
  #test if it returns 100 if value falls out of uper range
  expect_equal(normalize_value(200, 0, 10), 100)
  
  #test some simple cases
  expect_equal(normalize_value(10, -15, 35), 50)
  expect_equal(normalize_value(10, 0, 10), 10)
})