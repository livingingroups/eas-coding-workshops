if(basename(getwd()) == 'tests') setwd('..')

# Import testing library and file with functions to test
library(testthat)
source('./code/add_time_lag.R')


test_that("Test against sample dataset", {
  
  sifaka.sched <- read.csv('./test_data/input_add_time_lag.csv')
  
  expected_result <- read.csv('./test_data/output_add_time_lag.csv')
  
  actual_result <- add_time_lag(sifaka.sched)
  
  expect_equal(expected_result, actual_result)
})