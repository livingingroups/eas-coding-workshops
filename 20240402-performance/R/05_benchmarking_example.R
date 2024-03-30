library(tidyverse)
library(foreach)
library(doParallel)
library(data.table)
library(parallel)
library(microbenchmark)

orig <- function(GPS_data){
  GPS_data$study.local.timestamp <- as.POSIXct(GPS_data$study.local.timestamp)

  GPS_data <- arrange(GPS_data, individual.local.identifier, tag.local.identifier, study.local.timestamp)
  GPS_data$fix_id <- NA
  id.counter <- 1
  for (i in 1:nrow(GPS_data)) {
    if (!is.na(GPS_data$fix_id[i]))
      next
    date.i <- GPS_data$date[i]
    tag.i <- GPS_data$tag.local.identifier[i]
    animal.i <- GPS_data$individual.local.identifier[i]
    id.indicies <- i
    id.size <- 0
    while (id.size != length(id.indicies)) {
      id.size <- length(id.indicies)
      time.min.i <- min(GPS_data$study.local.timestamp[id.indicies])
      time.max.i <- max(GPS_data$study.local.timestamp[id.indicies])
      id.indicies <- unique(c(id.indicies,
                              which(GPS_data$date == date.i &
                                      GPS_data$tag.local.identifier == tag.i &
                                      GPS_data$individual.local.identifier == animal.i &
                                      GPS_data$study.local.timestamp >= (time.min.i - 10) &   #time within 10 seconds
                                      GPS_data$study.local.timestamp <= (time.max.i + 10))))   #time within 10 seconds
    }
    GPS_data$fix_id[id.indicies] <- id.counter
    id.counter <- id.counter + 1
  }
  return(GPS_data)
}

do_less <- function(GPS_data){
  GPS_data$study.local.timestamp <- as.POSIXct(GPS_data$study.local.timestamp)

  GPS_data <- arrange(GPS_data, individual.local.identifier, tag.local.identifier, study.local.timestamp)
  GPS_data$fix_id <- NA
  id.counter <- 1
  for (i in 1:nrow(GPS_data)) {
    if (!is.na(GPS_data$fix_id[i]))
      next
    date.i <- GPS_data$date[i]
    tag.i <- GPS_data$tag.local.identifier[i]
    animal.i <- GPS_data$individual.local.identifier[i]
    same_date_tag_individual <- {
      GPS_data$date == date.i &
      GPS_data$tag.local.identifier == tag.i &
      GPS_data$individual.local.identifier == animal.i
    }
    id.indicies <- i
    id.size <- 0
    new_indices_added <- FALSE
    while (!new_indices_added)  {
      new_indices_added <- FALSE
      id.size <- length(id.indicies)
      time.min.i <- min(GPS_data$study.local.timestamp[id.indicies])
      time.max.i <- max(GPS_data$study.local.timestamp[id.indicies])
      new.indicies <- which(
        same_date_tag_individual &
        GPS_data$study.local.timestamp >= (time.min.i - 10) &   #time within 10 seconds
        GPS_data$study.local.timestamp <= (time.max.i + 10)
      )
      new_indices_added <- length(new.indicies) > 0
      id.indicies <- c(id.indicies, new.indicies)   #time within 10 seconds
    }
    GPS_data$fix_id[unique(id.indicies)] <- id.counter
    id.counter <- id.counter + 1
  }
  return(GPS_data)
}

with_foreach <- function(GPS_data){
  GPS_data$study.local.timestamp <- as.POSIXct(GPS_data$study.local.timestamp)

  GPS_data <- arrange(GPS_data, individual.local.identifier, tag.local.identifier, study.local.timestamp)
  GPS_data$fix_id <- NA
  GPS_data$date.tag.individual <- paste0(
    GPS_data$date,
    GPS_data$tag.local.identifier,
    GPS_data$individual.local.identifier
  )
  unique_date_tag_individual <- unique(GPS_data$date.tag.individual)

  GPS_data <- foreach(j=1:length(unique_date_tag_individual), .combine = rbind) %dopar% {
    date.tag.individual <- unique_date_tag_individual[j]
    candidate.indices <- which(GPS_data$date.tag.individual == date.tag.individual)
    # Let each date individual, tag have its own id counter
    id.counter <- 1 + 1000*j
    for (i in candidate.indices) {
      if (!is.na(GPS_data$fix_id[i]))
        next
      date.i <- GPS_data$date[i]
      tag.i <- GPS_data$tag.local.identifier[i]
      animal.i <- GPS_data$individual.local.identifier[i]
      same_date_tag_individual <- {
        GPS_data$date == date.i &
        GPS_data$tag.local.identifier == tag.i &
        GPS_data$individual.local.identifier == animal.i
      }
      id.indicies <- i
      id.size <- 0
      new_indices_added <- FALSE
      while (!new_indices_added)  {
        new_indices_added <- FALSE
        id.size <- length(id.indicies)
        time.min.i <- min(GPS_data$study.local.timestamp[id.indicies])
        time.max.i <- max(GPS_data$study.local.timestamp[id.indicies])
        new.indicies <- which(
          same_date_tag_individual &
          GPS_data$study.local.timestamp >= (time.min.i - 10) &   #time within 10 seconds
          GPS_data$study.local.timestamp <= (time.max.i + 10)
        )
        new_indices_added <- length(new.indicies) > 0
        id.indicies <- c(id.indicies, new.indicies)   #time within 10 seconds
      }
      GPS_data$fix_id[unique(id.indicies)] <- id.counter
      id.counter <- id.counter + 1
    }
    GPS_data[same_date_tag_individual,]
  }
  # Revert to one fix_id counting system
  GPS_data$fix_id <- as.numeric(factor(GPS_data$fix_id, levels=unique(GPS_data$fix_id)))
  GPS_data$date.tag.individual <- NULL
  return(GPS_data)
}

with_data_frame <- function(GPS_data){
  GPS_data$study.local.timestamp <- as.POSIXct(GPS_data$study.local.timestamp)
  GPS_data <- arrange(GPS_data, individual.local.identifier, tag.local.identifier, study.local.timestamp)
  GPS_data$diff_previous = GPS_data$study.local.timestamp - shift(GPS_data$study.local.timestamp)
  GPS_data$new_tag_study_day =
      GPS_data$individual.local.identifier != shift(GPS_data$individual.local.identifier) |
      GPS_data$tag.local.identifier != shift(GPS_data$tag.local.identifier) |
      GPS_data$date != shift(GPS_data$date)
  GPS_data$is_first_obs_of_fix = GPS_data$diff_previous > 10 |
        GPS_data$new_tag_study_day
  GPS_data[which(is.na(GPS_data$is_first_obs_of_fix)),]$is_first_obs_of_fix = TRUE
  GPS_data[which(GPS_data$is_first_obs_of_fix == TRUE), 'fix_id'] = 1:sum(GPS_data$is_first_obs_of_fix)
  # using one tidyr function here
  # https://stackoverflow.com/a/61655676
  GPS_data$fix_id = fill(GPS_data, fix_id)$fix_id
  GPS_data$diff_previous = NULL
  GPS_data$new_tag_study_day = NULL
  GPS_data$is_first_obs_of_fix = NULL
  return(GPS_data)
}

with_data_table <- function(GPS_data){
  GPS_data <- data.table(GPS_data)
  GPS_data$study.local.timestamp <- as.POSIXct(GPS_data$study.local.timestamp)
  GPS_data <- GPS_data[order(individual.local.identifier, tag.local.identifier, study.local.timestamp)]
  GPS_data[,
    diff_previous := study.local.timestamp - shift(study.local.timestamp)
  ][,
    new_tag_study_day :=
      individual.local.identifier != shift(individual.local.identifier) |
      tag.local.identifier != shift(tag.local.identifier) |
      date != shift(date)
  ][,
    is_first_obs_of_fix :=
      diff_previous > 10 |
        new_tag_study_day
  ][
    is.na(is_first_obs_of_fix),
    is_first_obs_of_fix := TRUE,
  ][
    is_first_obs_of_fix == TRUE,
    fix_id := 1:sum(is_first_obs_of_fix)
  ][,
    fix_id := nafill(fix_id, 'locf'),
  ][,
    `:=`(
      diff_previous = NULL,
      new_tag_study_day = NULL,
      is_first_obs_of_fix = NULL
    )
  ]
  return(as.data.frame(GPS_data))
}

# Measurement ---------

## Setup ----
DATA_DIR <- './data'
input <- read.csv(file.path(DATA_DIR, 'input_optim.csv'))
expected_output <- read.csv(file.path(DATA_DIR, 'output_optim.csv'))
expected_output$study.local.timestamp <- as.POSIXct(expected_output$study.local.timestamp)

cl <- makeCluster(detectCores() - 1, FORK = T)
registerDoParallel(cl)

## Check Correctness ----

print(all(expected_output == orig(input)))
print(all(expected_output == do_less(input)))
print(all(expected_output == with_foreach(input)))
print(all(expected_output == with_data_frame(input)))
print(all(expected_output == with_data_table(input)))


## Benchmark ----

library(microbenchmark)

microbenchmark_results <- microbenchmark(
  orig(input),
 #do_less(input),
 #with_foreach(input),
 #with_data_frame(input),
 #with_data_table(input),
  times = 10
)

boxplot(microbenchmark_results)

stopCluster(cl)
