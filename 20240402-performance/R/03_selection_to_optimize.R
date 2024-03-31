DATA_DIR <- './data'

GPS_data <- read.csv(file.path(DATA_DIR, 'input_optim.csv'))
GPS_data$study.local.timestamp <- as.POSIXct(GPS_data$study.local.timestamp)

GPS_data <- arrange(GPS_data, individual.local.identifier, tag.local.identifier, study.local.timestamp)
GPS_data$fix_id <- NA
id.counter <- 1
pb <- txtProgressBar(min = 0, max = nrow(GPS_data), style = 3)
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
  rm(time.min.i)
  rm(time.max.i)
  setTxtProgressBar(pb, i)
}
rm(id.counter)
rm(id.indicies)
rm(id.size)
close(pb)
rm(pb)
summary(GPS_data$fix_id)
