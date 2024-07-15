library(kit)

input_df <- structure(list(group1 = c('REDACTED'),
                           group2 = c('REDACTED'),
                           date = structure(c('REDACTED'), class = "Date"),
                           dy_name = c('REDACTED'),
                           cosleep_last_night = c(NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA),
                           cosleep_tonight = c(NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, NA, NA, NA, NA)),
                      row.names = c(1L, 2L, 3L,
5L, 6L, 9L, 13L, 14L, 15L, 17L, 18L, 21L, 25L, 26L, 27L, 29L,
30L, 33L, 37L, 38L, 39L, 41L, 42L, 45L, 49L, 50L, 51L, 53L, 54L,
57L, 61L, 62L, 63L, 65L, 66L, 69L, 73L, 74L, 75L, 77L, 78L, 81L,
85L, 86L, 87L, 89L, 90L, 93L, 97L, 98L, 99L, 101L, 102L, 105L,
109L, 110L, 111L, 113L, 114L, 117L, 121L, 122L, 123L, 125L, 126L,
129L, 133L, 134L, 135L, 137L, 138L, 140L, 142L, 143L, 144L, 146L,
147L, 149L), class = "data.frame")

orig <- function(daily_df, spec_df){
  cosleep_last_night <- rep(0, nrow(daily_df))
  cosleep_tonight <- rep(0, nrow(daily_df))
  for( i in 1:nrow( daily_df ) ){

    # check whether the two groups sleep together on the previous night

    sleep_site_1 <- unique( spec_df[ spec_df$group1 == daily_df$group1[ i ] & spec_df$date == as.Date( daily_df$date[ i ] - 1, origin = '1970-01-01' ), 'sleep_clus' ] )

    sleep_site_1 <- sleep_site_1[ !is.na( sleep_site_1 ) ]

    sleep_site_2 <- unique( spec_df[ spec_df$group1 == daily_df$group2[ i ] & spec_df$date == as.Date( daily_df$date[ i ] - 1, origin = '1970-01-01' ), 'sleep_clus' ] )

    sleep_site_2 <- sleep_site_2[ !is.na( sleep_site_2 ) ]

    if( length( sleep_site_1 ) > 1 | length( sleep_site_2 ) > 1 ) stop( 'more than one sleep site for this day' )

    ## if we know where both groups slept on the previous night
    if( length( sleep_site_1 ) == 1 & length( sleep_site_2 ) == 1  ){

      # add whether they slept at the same site or not as a binary variable to the dataframe
      daily_df$cosleep_last_night[ i ] <- as.numeric( sleep_site_1 == sleep_site_2 )

    }


    # same for current night

    sleep_site_1 <- unique( spec_df[ spec_df$group1 == daily_df$group1[ i ] & spec_df$date == as.Date( daily_df$date[ i ], origin = '1970-01-01' ), 'sleep_clus' ] )

    sleep_site_1 <- sleep_site_1[ !is.na( sleep_site_1 ) ]

    sleep_site_2 <- unique( spec_df[ spec_df$group1 == daily_df$group2[ i ] & spec_df$date == as.Date( daily_df$date[ i ], origin = '1970-01-01' ), 'sleep_clus' ] )

    sleep_site_2 <- sleep_site_2[ !is.na( sleep_site_2 ) ]

    if( length( sleep_site_1 ) > 1 | length( sleep_site_2 ) > 1 ) stop( 'more than one sleep site for this day' )

    ## if we know where both groups slept on the current night
    if( length( sleep_site_1 ) == 1 & length( sleep_site_2 ) == 1  ){

      # add whether they slept at the same site or not as a binary variable to the dataframe
      daily_df$cosleep_tonight[ i ] <- as.numeric( sleep_site_1 == sleep_site_2 )

    }
  }
  return(data.frame(
    cosleep_last_night = daily_df$cosleep_last_night,
    cosleep_tonight = daily_df$cosleep_tonight
  ))
}

vectorized <- function(daily_df, spec_df){

  # this is equivalent to
  # unique(spec_df[, c('date', 'group1', 'sleep_clus')])
  # but *much* faster
  # duplicate is from the kit package
  sleep_site_df <- spec_df[
    !fduplicated(spec_df[, c('date', 'group1', 'sleep_clus')]),
    c('date', 'group1', 'sleep_clus')
    ]

  # Check for more than one site in the same day.
  # If multiple sites, the second expression will have fewer rows than the first.
  stopifnot(nrow(sleep_site_df) == nrow(unique(sleep_site_df[, c('date', 'group1')])))

  daily_df_working <- daily_df
  daily_df_working$row_idx <- 1:nrow(daily_df_working)
  daily_df_working$prev  <- as.Date(daily_df$date - 1, origin = '1970-01-01')
  daily_df_working$curr  <- as.Date(daily_df$date, origin = '1970-01-01')
  daily_df_working$sleep_clus <- NA

  for(group in c('group1', 'group2')){
    for(curr_or_prev in c('curr', 'prev')){
      daily_df_working <- merge(
        daily_df_working,
        sleep_site_df,
        by.x = c(
          group,
          curr_or_prev
        ),
        by.y = c(
          'group1',
          'date'
        ),
        sort = FALSE,
        all.x = TRUE,
        suffixes = c('', paste('', group, curr_or_prev, sep = '_'))
      )

    }
  }
  daily_df_working <- daily_df_working[order(daily_df_working$row_idx),]

  return(data.frame(
    cosleep_last_night = as.numeric(daily_df_working$sleep_clus_group1_prev == daily_df_working$sleep_clus_group2_prev),
    cosleep_tonight = as.numeric(daily_df_working$sleep_clus_group1_curr == daily_df_working$sleep_clus_group2_curr)
  ))
}

if(SUBSET){spec_df <- read.csv("bab_dyad_subset.csv")}else{spec_df <- read.csv("bab_dyad.csv")}
spec_df$local_timestamp <- as.POSIXct( spec_df$local_timestamp, tz = 'UTC' )

spec_df$date <- as.Date( spec_df$local_timestamp )

spec_df$dy_name <- dy_name(spec_df$group1, spec_df$group2)

#now duplicate the main df but take out overnight data
spec_df$time_only <- as_hms(spec_df$local_timestamp)

orig_result <- orig(input_df, spec_df)
vectorized_result <- vectorized(input_df, spec_df)
testthat::expect_equal(orig_result, vectorized_result)

print(microbenchmark(
  orig(input_df, spec_df),
  vectorized(input_df, spec_df),
  times = 10
  ,check = 'equal'
))


