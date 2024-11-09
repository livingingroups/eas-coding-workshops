
# Import testing library and file with functions to test
source('./add_deployment_id.R')


# Test against sample dataset"
reference <- read.csv('./test_data/input_reference.csv')
test.sched <- read.csv('./test_data/input_add_deployment_id.csv')

expected_result <- read.csv('./test_data/output_add_deployment_id.csv')

actual_result <- add_deployment_id(test.sched, reference)

expect_equal(expected_result, actual_result)


small_reference <- data.frame(
  local.deploy.on.date = 0,
  local.deploy.off.date = 12,
  tag.id = 8,
  animal.id = 'TEST',
  deployment.id = 'first_deployment'
)

# 3rd row is an example of NA deployment ID
small_schedule <- data.frame(
  start_datetime = c(2, 10, 18),
  stop_datetime = c(4, 11, 20),
  tag.local.identifier = 8
)

actual <- add_deployment_id(small_schedule, small_reference)

test_that("exammple testa", {
  expect_equal(
    add_deployment_id(small_schedule, small_reference)$deployment.id,
    c('first_deployment', 'first_deployment', NA)
  )
})
