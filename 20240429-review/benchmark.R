
test_df_in <- data.frame(
  group1 = c('REDACTED'),
                          group2 = c('REDACTED'))

test_out <- c('REDACTED')

orig <- function(df_in) apply( df_in[,c('group1', 'group2')], 1, function( x ) paste( sort( x ), collapse = '-' ) )
vectorized <- function(df_in){
  # candidate 1
  c1 <- paste(df_in$group1, df_in$group2, sep = '-')
  # candidate 2
  c2 <- paste(df_in$group2, df_in$group1, sep = '-')
  # pmin = vectorized min. For strings this means first alphabetically.
  return(pmin(c1,c2))
}


testthat::expect_equal(orig(test_df_in), test_out)
testthat::expect_equal(vectorized(test_df_in), test_out)

library(microbenchmark)

microbenchmark_results <- microbenchmark(
  orig(test_df_in),
  vectorized(test_df_in),
  times = 10
)

print(microbenchmark_results)
