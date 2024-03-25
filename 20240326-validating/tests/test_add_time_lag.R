if(basename(getwd()) == 'tests') setwd('..')

# Import testing library and file with functions to test
library(testthat)
source('./R/add_time_lag.R')


test_that("Test against sample dataset", {

  sifaka.sched <- read.csv('./test_data/input_add_time_lag.csv')

  expected_result <- read.csv('./test_data/output_add_time_lag.csv')

  actual_result <- add_time_lag(sifaka.sched)

  expect_equal(expected_result, actual_result)
})

# Hint:
# You can strings into difftime in this format:
#
# > difftime('2022-01-03 8:32', '2022-01-03 8:30', units = 'mins')
# Time difference of 2 mins
#
# or input integers, and difftime will interpret it as seconds
# > difftime(10 * 60, 8 * 60, units = 'mins')
# Time difference of 2 mins
#
# Therefore, in you can format sifaka.sched$start_datetime in this way
# in your input dataframe.
