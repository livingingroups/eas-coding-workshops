# Example of writing the same set of test two ways
# imo the first one is more readable although it is less DRY
# this is a demonstration of tests not needing to be DRY.
# see https://r-pkgs.org/testing-design.html#repetition-is-ok

# Note: these tests will fail unless the bug in better_shapes.R is fixed
library(testthat)
library(mypackage)

test_that('Repetition example', {
  expect_equal(calculate_shape_area('square', list(l = 1)), 1)
  expect_equal(calculate_shape_area('square', list(l = 2)), 4)
  expect_equal(calculate_shape_area('square', list(l = 5)), 25)
  expect_equal(calculate_shape_area('square', list(l = 8)), 64)
})

test_that('for loop example', {
  square_examples <- data.frame(
    l = c(1, 2, 5, 8),
    area = c(1, 4, 25, 64)
  )

  for (i in 1:nrow(square_examples)) {
    expect_equal(
      calculate_shape_area(
        'square',
        list(l = square_examples[i, 1])),
      square_examples[i, 2]
    )
  }
})
