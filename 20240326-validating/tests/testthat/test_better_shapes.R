library(testthat)
library(mypackage)

test_that("process function is working on sample input", {
  shapes <- "firstshape: circle (r=3)
secondshape: square (l=5)
bluerect: rectangle (l=8,w=2)
secondsquare: square (l=1)
redrect: rectangle (l=45,w=100)"

  actual_output <- process(shapes)

  expected_output <- read.table(
    text = "name, type, area
firstshape, circle, 28.27433388
secondshape, square, 25
bluerect, rectangle, 16
secondsquare, square, 1
redrect, rectangle, 4500",
    sep = ',',
    header = TRUE
  )

  expect_equal(actual_output$area, expected_output$area)
})

test_that('parsing function is working with sample input', {
  input <- 'secondshape: square (l=5)'

  # output
  expected_output <- list(shape_name = 'secondshape',
                          shape_type = 'square',
                          params = list(l = 5))

  actual_output <- parse_shape_definition_line(input)

  expect_equal(expected_output$shape_name, actual_output$shape_name)
  expect_equal(expected_output$shape_type, actual_output$shape_type)
})

test_that('parsing function is working with triangle', {
  input <- 'sample_triangle: triangle (a=1, b=2, c=3)'

  # output
  expected_output <- list(
    shape_name = 'sample_triangle',
    shape_type = 'triangle',
    params = list(a = 1,
                  b = 2,
                  c = 3)
  )

  actual_output <- parse_shape_definition_line(input)

  expect_equal(actual_output, expected_output)
})

test_that('area calculation is working',{
  expect_equal(calculate_shape_area('square', list(l=5)), 25)
})
