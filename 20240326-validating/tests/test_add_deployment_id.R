setwd('..') # Set wd to 20240326-validating, skip this is already the wd

# Import testing library and file with functions to test
library(testthat)
source('./code/add_deployment_id.R')


test_that("Test against sample dataset", {
  reference <- read.csv('./test_data/input_reference.csv')
  test.sched <- read.csv('./test_data/input_add_deployment_id.csv')
  
  expected_result <- read.csv('./test_data/output_add_deployment_id.csv')
  
  actual_result <- add_deployment_id(test.sched, reference)
  
  expect_equal(expected_result, actual_result)
})