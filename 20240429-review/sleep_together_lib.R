

check_sleep_together <- function(spec_df){
  f(SUBSET){spec_df <- read.csv("bab_dyad_subset.csv")}else{spec_df <- read.csv("bab_dyad.csv")}

  head( spec_df )

  spec_df$local_timestamp <- as.POSIXct( spec_df$local_timestamp, tz = 'UTC' )

  spec_df$date <- as.Date( spec_df$local_timestamp )

  spec_df$dy_name <- apply( spec_df[ , c( 'group1', 'group2' ) ], 1, function( x ) paste( sort( x ), collapse = '_' ) )

  #now duplicate the main df but take out overnight data
  str(spec_df)
  spec_df$time_only <- as_hms(spec_df$local_timestamp)
  spec_df_day <- droplevels(subset(spec_df, time_only <= as_hms("17:30:00") & time_only >= as_hms("08:30:00")))


  ### find typical intragroup dists ###
  groupmate_df_day <- spec_df_day[ spec_df_day$group1 == spec_df_day$group2 & spec_df_day$id1 != spec_df_day$id2, ]
  groupmate_df_day <- groupmate_df_day[ !duplicated( groupmate_df_day$local_timestamp ), ]
  hist( groupmate_df_day$dyadDist )
  group_spread_dist_day <- quantile( groupmate_df_day$dyadDist, quant, na.rm = T )
  group_spread_dist_day #84.85
  abline( v = group_spread_dist_day, col = 'red' )


  # By DAY --------------------------------------------------------------------------------------------
  #### First, determine if 2 groups shared a sleep site the night before or the next night, use all data

  daily_df <- unique( spec_df[ , c( 'group1', 'group2', 'date' ) ] )

  daily_df <- daily_df[ daily_df$group1 != daily_df$group2, ]

  daily_df$dy_name <- apply( daily_df[ , c( 'group1', 'group2' ) ], 1, function( x ) paste( sort( x ), collapse = '-' ) )

  rownames( daily_df ) <- NULL

  daily_df <- daily_df[ ! duplicated( daily_df[ , c( 'dy_name', 'date' ) ]  ), ]

  daily_df$cosleep_last_night <- NA
  daily_df$cosleep_tonight <- NA

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

  # NA value means missing data for one or both groups
  # 0 means no share
  # 1 means shared

  #get summary stats
  sum( daily_df$cosleep_last_night == 0, na.rm = T) #this sum hasn't changed
  sum( daily_df$cosleep_last_night == 1, na.rm = T) #this sum hasn't changed




  return(day_df)
}
