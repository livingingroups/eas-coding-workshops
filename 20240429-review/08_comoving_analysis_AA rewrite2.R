library( stringr )
library( ggplot2 )
library( hms )
library( dplyr )

## fcn to provide a unique name to each unique group dyad
dy_name <- function(group1, group2) {
  # candidate 1
  c1 <- paste(group1, group2, sep = '-')
  # candidate 2
  c2 <- paste(group2, group1, sep = '-')
  # pmin = vectorized min. For strings this means first alphabetically.
  return(pmin(c1,c2))
}

# SET UP -------------------------------------------------------------------------------------------

### user-inputs ###

SUBSET <- TRUE

dist_thresh <- 600

quant <- 0.80 ## quantile of intra-group dyadic distances to determine the maximum allowable

samp_int <- 15 ## sampling interval -- this should stay at 15

# Why 100?? what's so great about 100???
min_move <- 100 ## minimum distance required to move while being within the distance set by the quant variable above to be considered a co-move

min_comove_duration <- 0 ## minimum duration required remain iwthin the distance set by the quant variable above to be considered a co-move

# median departure time and arrival time at the sleep site, respectively. These are determined in a previous script (but could be determined here instead of hard-coding before publishing)
median_leave_time <- "08:30:00"
median_arrive_time <- "17:30:00"



# bring in data

if(SUBSET){spec_df <- read.csv("bab_dyad_subset.csv")}else{spec_df <- read.csv("bab_dyad.csv")}

head( spec_df )

spec_df$local_timestamp <- as.POSIXct( spec_df$local_timestamp, tz = 'UTC' )

spec_df$date <- as.Date( spec_df$local_timestamp )

spec_df$dy_name <- dy_name(spec_df$group1, spec_df$group2)

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



# By ENCOUTER --------------------------------------------------------------------------------------------
#### Second, for each interaction, determine if the two groups moved together, and if so, did they comove together

#enc_df <- readRDS("baboons_dyadDurat_dayonly.rds") #from script 7
#rownames(enc_df) <- NULL

if(SUBSET){enc_df <- read.csv("enc_df_subset.csv")} else {enc_df <- read.csv("enc_df.csv")}

enc_df$start_local_timestamp <- as.POSIXct(enc_df$start_local_timestamp, tz='UTC')
enc_df$end_local_timestamp <- as.POSIXct(enc_df$end_local_timestamp, tz='UTC')

#prep
spec_df_day$dy_name <- dy_name(spec_df_day$group1, spec_df_day$group2)

enc_df <- enc_df[order(enc_df$dyadID, enc_df$start_local_timestamp ),]
enc_df$enc_number <- 1:nrow(enc_df)
enc_df$move_together_group1 <- 0
enc_df$move_together_group2 <- 0
enc_df$comove <- 0

#need comove_df
comove_df <- data.frame(cbind(dy_name = rep(NA, 200),
                              enc_number = rep(NA, 200),
                              start_local_timestamp = rep(0, 200),
                              end_local_timestamp = rep(0, 200),
                              move_comove_group_1 = rep(NA, 200),
                              move_comove_group_2 = rep(NA, 200),
                              dur_comove = rep(NA, 200)))
c <- 1 #start a comove_df row counter

for (i in 1:nrow(enc_df)) {
  print(i)
  #subset to just get gps data from within the time of the interaction
  spec_df_sub <- droplevels(subset(spec_df_day, spec_df_day$dy_name == enc_df$dyadID[i] &
                                     spec_df_day$local_timestamp >= enc_df$start_local_timestamp[i] &
                                     spec_df_day$local_timestamp <= enc_df$end_local_timestamp[i]))


  ## DIST MOVED TOGETHER ##
  # where there is more than one indiv in the group, sort out which one to use
  #make df for group 1
  group1_df <- spec_df_sub[ spec_df_sub$group1 == enc_df$group1[ i ], ]

  #figure out which individual (if there is >1 has the most data)
  id_to_use <- names( table( group1_df$id1 ) )[ which.max( table( group1_df$id1 ) ) ]
  #use that individual's data
  id1_df <- group1_df[ group1_df$id1 == id_to_use, ]
  #sort it by intergroup distance (#in case other group also has >1 collared indiv, the next two lines take out the farther away indiv)
  id1_df <- id1_df[ order( id1_df$dyadDist ), ]
  #remove duplicates
  id1_df_no_dup <- id1_df[ !duplicated( id1_df$local_timestamp ), ]
  #sort it by time
  id1_df_no_dup <- id1_df_no_dup[ order( id1_df_no_dup$local_timestamp ), ]

  #do all the same for the other groups
  group2_df <- spec_df_sub[ spec_df_sub$group1 == enc_df$group2[ i ], ]
  id_to_use <- names( table( group2_df$id1 ) )[ which.max( table( group2_df$id1 ) ) ]
  id2_df <- group2_df[ group2_df$id1 == id_to_use, ]
  id2_df <- id2_df[ order( id2_df$dyadDist ), ]
  id2_df_no_dup <- id2_df[ !duplicated( id2_df$local_timestamp ), ]
  id2_df_no_dup <- id2_df_no_dup[ order( id2_df_no_dup$local_timestamp ), ]

  #calculate distances moved together, dump into enc_df

  # greater than for the first part because the step taken to get into an encounter does not count towards the distance traveled together while in an encounter
  time_sub_1 <- id1_df_no_dup[ id1_df_no_dup$local_timestamp > enc_df$start_local_timestamp[ i ] & id1_df_no_dup$local_timestamp <= enc_df$end_local_timestamp[ i ], ]
  enc_df$move_together_group1[ i ] <- sum( time_sub_1$spat.disc.dist ) ##so moved distance is SUM OF EACH STEP, not displacement

  # greater than for the first part because the step taken to get into an encounter does not count towards the distance traveled together while in an encounter
  time_sub_2 <- id2_df_no_dup[ id2_df_no_dup$local_timestamp > enc_df$start_local_timestamp[ i ] & id2_df_no_dup$local_timestamp <= enc_df$end_local_timestamp[ i ], ]
  enc_df$move_together_group2[ i ] <- sum( time_sub_2$spat.disc.dist )

  rm(time_sub_1, time_sub_2)
  ## COMOVEMENT ##

  spec_df_sub_min <- aggregate( spec_df_sub$dyadDist, by = list( spec_df_sub$local_timestamp, spec_df_sub$dy_name ), FUN = min, na.rm = T )
  names( spec_df_sub_min ) <- c( 'local_timestamp', 'dy_name', 'dyadDist' )
  spec_df_sub_min <- spec_df_sub_min[ order( spec_df_sub_min$local_timestamp ), ]

  #all times when within the comovement threshold
  comoving_sub <- spec_df_sub_min[ spec_df_sub_min$dyadDist < group_spread_dist_day, ] ######################### use group_spread_dist OR group_spread_dist_day????

  if( nrow( comoving_sub ) != 0 ){ # if the dyad comes within this distance of each other... then determine if cohesive movement occured
    print(paste(i, "in maybe comove if"))
    # find the time differences between observations of potential encounters
    diff_min <- as.numeric( diff(comoving_sub$local_timestamp), units = 'mins' )
    # find out how many of these are consecutive GPS fixes
    tsig <- c(F,(abs(diff_min) == samp_int))
    # find the indices that represent the start of a potential encounter (i.e. more than the sampling interval after the previous time the dyad was in close proximity)
    startIndex <- which(tsig == F)
    # find the indices associated with the ends of potential encounters (when the next time of close proximity is more than the sampling interval after an observation of proximity)
    endIndex <- c((startIndex[-1] - 1), nrow(comoving_sub))

    start_times <- comoving_sub$local_timestamp[startIndex]
    end_times <- comoving_sub$local_timestamp[endIndex]
    dur_interact <- as.numeric( end_times - start_times, units = 'mins')

    num_of_possible_comoves <- which( dur_interact >= min_comove_duration )

    for (j in seq_along(num_of_possible_comoves)) {
      print(paste(i, ", ", j))

      # greater than for the first part because the step taken to get into an encounter does not count towards the distance traveled together while in an encounter
      time_sub_1 <- id1_df_no_dup[ id1_df_no_dup$local_timestamp > start_times[ j ] & id1_df_no_dup$local_timestamp <= end_times[ j ], ]

      # greater than for the first part because the step taken to get into an encounter does not count towards the distance traveled together while in an encounter
      time_sub_2 <- id2_df_no_dup[ id2_df_no_dup$local_timestamp > start_times[ j ] & id2_df_no_dup$local_timestamp <= end_times[ j ], ]

      if( sum( time_sub_1$spat.disc.dist, na.rm = T ) > min_move & sum( time_sub_2$spat.disc.dist, na.rm = T ) > min_move ){ # if both groups exceed distance threshold
        print(paste(i, "yes to comove"))

        enc_df$comove[i] <- enc_df$comove[i] + 1 #count up the number of comove bouts for that encounter

        comove_df$dy_name[c] <- enc_df$dyadID[i]
        comove_df$enc_number[c] <- enc_df$enc_number[i]
        #now save the relevant info about the comovement bout
        #start & end time
        print(start_times[j])
        print(end_times[j])
        comove_df$start_local_timestamp[c] <- start_times[ j ]
        comove_df$end_local_timestamp[c] <- end_times[ j ]
        comove_df$dur_comove[c] <-  as.numeric( end_times[ j ] - start_times[ j ], units = "mins" )

        #distances travelled
        comove_df$move_comove_group_1[c] <- sum( time_sub_1$spat.disc.dist )
        comove_df$move_comove_group_2[c] <- sum( time_sub_2$spat.disc.dist )

        #count up the comove row index
        c <- c + 1

      } # close if comove >= minmove statement

      rm(time_sub_1, time_sub_2)
    } #close j loop
  } # close if comove = true statement
} # close i loop

comove_df <- droplevels(subset(comove_df, is.na(comove_df$dur_comove) != TRUE))
sum(enc_df$comove) == nrow(comove_df) ##SHOULD BE TRUE!!!

comove_df$start_local_timestamp <- as.POSIXct(comove_df$start_local_timestamp, origin = '1970-01-01', tz = "UTC")
comove_df$end_local_timestamp <- as.POSIXct(comove_df$end_local_timestamp, origin = '1970-01-01', tz = "UTC")

comove_df$date <- as.Date( comove_df$start_local_timestamp )
enc_df$date <- as.Date( enc_df$start_local_timestamp )

enc_df <- left_join(enc_df, daily_df)

comove_df <- left_join(comove_df, daily_df)

# Exploring Output ---------------------------------------------------------------------------------

# > COHESIVE MOVT ------------------------------------------------------------------------------------
### Get basic summary stats for cohesive movement

comove_by_day <- comove_df %>%
  group_by(dy_name, date) %>%
  summarize(total_move_comove_group_1 = sum(move_comove_group_1),
            total_move_comove_group_2 = sum(move_comove_group_2),
            total_dur_comove = sum(dur_comove),
            mean_total_comove = mean(total_move_comove_group_1, total_move_comove_group_2),
            cosleep_last_night = mean(cosleep_last_night))

#on how many days was there comovement
nrow(comove_by_day)

#on how many days did comove happen after cosleep
nrow(subset(comove_by_day, cosleep_last_night == 1))
nrow(subset(comove_by_day, cosleep_last_night == 0))

#distance moved cohesively on days after sharing a sleep site
mean(comove_by_day$mean_total_comove[which(comove_by_day$cosleep_last_night == 1)])
#distance moved cohesively on days after NOT sharing a sleep site
mean(comove_by_day$mean_total_comove[which(comove_by_day$cosleep_last_night == 0)])

#duration of comovement on days after sharing a sleep site
mean(comove_by_day$total_dur_comove[which(comove_by_day$cosleep_last_night == 1)])
sd(comove_by_day$total_dur_comove[which(comove_by_day$cosleep_last_night == 1)])

#duration of comovement on days after NOT sharing a sleep site
mean(comove_by_day$total_dur_comove[which(comove_by_day$cosleep_last_night == 0)])
sd(comove_by_day$total_dur_comove[which(comove_by_day$cosleep_last_night == 0)])

saveRDS(comove_by_day, "RESULTS/Cohesive_movement_summary_byday.rds")


# > ALL ENCS ------------------------------------------------------------------------------------------
### Get basic summary stats for all encounters

enc_by_day <- enc_df %>%
  group_by(dy_name, date) %>%
  summarize(total_move_group_1 = sum(move_together_group1),
            total_move_group_2 = sum(move_together_group2),
            total_dur_enc = sum(duration),
            mean_total_move = mean(c(move_together_group1, move_together_group2)),
            cosleep_last_night = mean(cosleep_last_night))

#on how many days was there comovement
nrow(comove_by_day)
#number of encounters after cosleep
sum(enc_df$cosleep_last_night == 1, na.rm = T)
sum(enc_df$cosleep_last_night == 0, na.rm = T)

# >  PLOTS ---------------------------------------------------------------------------------------------

ggplot() +
  geom_boxplot(data = comove_by_day,
               mapping = aes(x = as.factor(cosleep_last_night),
                             y = total_dur_comove)) +
  geom_point(data = comove_by_day,
              mapping = aes(x = as.factor(cosleep_last_night),
                            y = total_dur_comove),
             position = position_jitter(width = 0.1),
             size = 4,
             alpha = 0.5) +
  scale_y_continuous(limits = c(0, 300))

ggplot() +
  geom_boxplot(data = comove_by_day,
               mapping = aes(x = as.factor(cosleep_last_night),
                             y = mean_total_comove)) +
  geom_point(data = comove_by_day,
             mapping = aes(x = as.factor(cosleep_last_night),
                           y = mean_total_comove),
             position = position_jitter(width = 0.1),
             size = 4,
             alpha = 0.5)



# ?SUPP FIGURE --------------------------------------------------------------------------------------
#### SUPPLEMENTARY FIGURE of ALL ENCOUNTERS plotted by TIME OF DAY

enc_df$start_time <- as_hms(enc_df$start_local_timestamp)
enc_df$end_time <- as_hms(enc_df$end_local_timestamp)

comove_df$start_time <- as_hms(comove_df$start_local_timestamp)
comove_df$end_time <- as_hms(comove_df$end_local_timestamp)

ggplot() +
  geom_segment(data = enc_df,
               mapping = aes(x = start_time,
                             xend = end_time,
                             y = paste(dyadID, date),
                             yend = paste(dyadID, date),
                             color = dyadID),
               linewidth = 2,
               lineend = "round") +
  geom_point(data = subset(enc_df, cosleep_last_night == 1),
             mapping = aes(x = as_hms("08:25:00"),
                           y = paste(dyadID, date)),
             shape = 8) +
  geom_point(data = subset(enc_df, cosleep_tonight == 1),
             mapping = aes(x = as_hms("17:35:00"),
                           y = paste(dyadID, date)),
             shape = 8) +
  geom_segment(data = comove_df,
               mapping = aes(x = start_time,
                             xend = end_time,
                             y = paste(dy_name, date),
                             yend = paste(dy_name, date)),
               color = "white",
               alpha = 0.9,
               linewidth = 1.5,
               lineend = "round")  +
  geom_text(data =  enc_df %>% group_by(dyadID) %>% slice(n()),
             mapping = aes(x = as_hms("08:20:00"),
                           y = paste(dyadID, date),
                           label = dyadID,
                           color = dyadID),
            hjust = 1,
            vjust = 1,
            fontface = "bold") +
  scale_color_manual(values = c( "#fd6100" , "#dc267f", "#785ef0", "#feb000","#648fff")) +
  scale_y_discrete(name = "Dyad - Day",
                   expand = c(0.02, 0)) +
  scale_x_time(name = "Time of day (08:30 to 17:30)",
               breaks = c(as_hms(c("08:30:00", "10:00:00", "12:00:00", "14:00:00", "16:00:00", "17:30:00"))),
               limits = c(as_hms(c("08:10:00", "17:37:00")))) +
  theme_bw()+
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        panel.border = element_blank(),
        legend.position = "none")
