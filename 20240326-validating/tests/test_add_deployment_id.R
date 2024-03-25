if(basename(getwd()) == 'tests') setwd('..')

# Import testing library and file with functions to test
library(testthat)
source('./R/add_deployment_id.R')


test_that("Test against sample dataset", {
  reference <- read.csv('./test_data/input_reference.csv')
  test.sched <- read.csv('./test_data/input_add_deployment_id.csv')

  expected_result <- read.csv('./test_data/output_add_deployment_id.csv')

  actual_result <- add_deployment_id(test.sched, reference)

  expect_equal(expected_result, actual_result)
})

test_that("Simple Matching works",{
  test.sched <- data.frame(
    'tag.local.identifier' = 1234,
    start_datetime = 2,
    stop_datetime = 10
  )
  ref <- data.frame(
    animal.id = 'TEST',
    tag.id = 1234,
    local.deploy.on.date = 1,
    local.deploy.off.date = 15,
    deployment.id = 'example_deployment_id'
  )

  expect_equal(
    add_deployment_id(test.sched, ref)$deployment.id,
    'example_deployment_id'
  )
})


test_that("Out of time range leaves deployment id NA",{
  test.sched <- data.frame(
    'tag.local.identifier' = 1234,
    start_datetime = 2,
    stop_datetime = 20
  )

  ref <- data.frame(
    animal.id = 'TEST',
    tag.id = 1234,
    local.deploy.on.date = 1,
    local.deploy.off.date = 15,
    deployment.id = 'example_deployment_id'
  )

  expect_equal(
    add_deployment_id(test.sched, ref)$deployment.id,
    NA
  )
})

test_that("Multiple matches results in NA",{
  test.sched <- data.frame(
    'tag.local.identifier' = 1234,
    start_datetime = 2,
    stop_datetime = 10
  )
  ref <- data.frame(
    animal.id = 'TEST',
    tag.id = c(1234, 1234),
    local.deploy.on.date = 1,
    local.deploy.off.date = 15,
    deployment.id = c('example_deployment_id_1', 'example_deployment_id_2')
  )

  expect_equal(
    add_deployment_id(test.sched, ref)$deployment.id,
    NA
  )
})
