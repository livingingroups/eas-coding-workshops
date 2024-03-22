#Set up workspace
rm(list = ls())
options(stringsAsFactors = F)
options(digits.secs = 3)
setwd("~/tracy")

#Load libraries
library(tidyverse)

#Load reference data

reference <- read.csv("Verreaux's sifaka & fosa at Ankoatsifaka-reference-data.csv")
reference$deploy.on.date <- as.POSIXct(reference$deploy.on.date, format = "%Y-%m-%d %H:%M:%OS")
reference$deploy.off.date <- as.POSIXct(reference$deploy.off.date, format = "%Y-%m-%d %H:%M:%OS")
reference$local.deploy.on.date <- reference$deploy.on.date + 3*60*60
reference$local.deploy.off.date <- reference$deploy.off.date + 3*60*60

#Load GPS data
GPS_data <- read.csv("subset.csv")

#Check for & remove columns that are all NA
na.test <-  function(x) {
  w <- sapply(x, function(x)all(is.na(x)))
  if (any(w)) {
    stop(paste("All NA in columns", paste(which(w), collapse = ", ")))
  }
}
#na.test(GPS_data)
GPS_data <- GPS_data[,-c(6, 9, 10, 21, 23, 24, 25, 27, 31, 40)]
na.test(GPS_data)
str(GPS_data)

#Fix times
GPS_data$timestamp <- as.POSIXct(GPS_data$timestamp, format = "%Y-%m-%d %H:%M:%OS")
GPS_data$study.local.timestamp <- as.POSIXct(GPS_data$study.local.timestamp, format = "%Y-%m-%d %H:%M:%OS")

#Create date column
GPS_data$date <- format(GPS_data$study.local.timestamp, format = "%Y-%m-%d")
GPS_data$date <- as.Date(GPS_data$study.local.timestamp, format = "%Y-%m-%d")

#Create time column
GPS_data$time <- format(GPS_data$study.local.timestamp, format = "%H:%M:%OS")
GPS_data$time <- as.POSIXct(GPS_data$time, format = "%H:%M:%OS")


#GPS data _______________________________________________________________

#Remove bad GPS data
nrow(GPS_data)
GPS_data <- filter(GPS_data, eobs.status == "A")     #remove 9937
nrow(GPS_data)

#Create z column - complex number combining easting & northing
GPS_data$Z <- GPS_data$utm.easting + 1i * GPS_data$utm.northing

#Look at z column
head(Re(GPS_data$Z))     #real = utm.easting
head(Im(GPS_data$Z))     #imaginary = utm.northing
head(Mod(GPS_data$Z))     #modulus  = magnitude = steplength_sec
head(Arg(GPS_data$Z))     #argument = direction = turnangle

#Divide into GPS fixes to look at TTF
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

#Save for later
GPS_data_save <- GPS_data
save(GPS_data_save, file = "intermediate_gps_05Jan2023.Rdata")

write.csv(GPS_data, 'output_identify_fixes.csv', row.names = F, quote = F)

# Start after for-loop ___________________________________________________

load("intermediate_gps_05Jan2023.Rdata")
GPS_data <- GPS_data_save

#Fix positions within 1 minute

# GPS_data[GPS_data$tag.local.identifier == 9379 & GPS_data$eobs.start.timestamp == "2022-07-04 03:34:02.000" &
#            GPS_data$fix_id == 125546,]$fix_id <- 125545
# GPS_data[GPS_data$tag.local.identifier == 9379 & GPS_data$eobs.start.timestamp == "2022-07-04 03:34:02.000" &
#            GPS_data$fix_id == 125547,]$fix_id <- 125545
# 
# GPS_data[GPS_data$tag.local.identifier == 9400 & GPS_data$fix_id == 13481,]$fix_id[2] <- max(GPS_data$fix_id) + 1
# GPS_data[GPS_data$tag.local.identifier == 9402 & GPS_data$fix_id == 25568,]$fix_id[2] <- max(GPS_data$fix_id) + 1

#Assign fix position in GPS bursts
GPS_data <- GPS_data %>%
  arrange(GPS_data, fix_id, study.local.timestamp) %>%
  group_by(fix_id) %>%
  mutate(fix_pos = 1:length(fix_id)) %>%
  ungroup()

#Sampling schedule
sched <- GPS_data %>% group_by(fix_id, tag.local.identifier) %>%
  summarise(species = individual.taxon.canonical.name[1],
            animal = individual.local.identifier[1],
            date = date[1],
            start_datetime = min(study.local.timestamp),
            stop_datetime = max(study.local.timestamp),
            num_fixes = max(fix_pos)) %>%
  ungroup()
sched$length_sec <- round(as.numeric(difftime(sched$stop_datetime,
                                              sched$start_datetime, units = "secs")), digits = 1)
summary(as.factor(sched$length_sec))

#Does fix_id match start.timestamp?
fix.check <- GPS_data %>% group_by(tag.local.identifier, eobs.start.timestamp) %>% summarise(num_fixes = length(unique(fix_id)))
fix.check <- filter(fix.check, num_fixes != 1)
# View(filter(GPS_data, tag.local.identifier == 9379 & eobs.start.timestamp == "2022-07-04 03:34:02.000"))
## Four fix_ids here
# 125544 - 2023-01-03 06:47:31
# 125545 - 2023-01-03 06:50:18 - 3 min break - separate fix_ids
# 125545 - 2023-01-03 06:50:23
# 125546 - 2023-01-03 06:50:38 - 15 sec break - same fix_id
# 125546 - 2023-01-03 06:54:29
# 125547 - 2023-01-03 06:55:19 - 50 sec break - same fix_id
# View(filter(GPS_data, tag.local.identifier == 9420 & eobs.start.timestamp == "2022-07-10 03:33:22.000"))
# 107559 - 2023-01-03 10:47:12
# 107560 - 2023-01-03 10:57:24 - 10 min break - separate fix_ids

fix.check2 <- GPS_data %>% group_by(fix_id) %>% summarise(num_fixes = length(unique(eobs.start.timestamp)))
fix.check2 <- filter(fix.check2, num_fixes != 1)
# View(filter(GPS_data, fix_id == 13481))
# View(filter(GPS_data, fix_id == 25568))
## Both are fosa - should be separate fixes because burst_length == 1


#Separate data points by sampling regime ______________________________________

#Separate sifaka data points
sifaka.sched <- filter(sched, species == "Propithecus verreauxi")
sifaka.sched$start_time <- format(sifaka.sched$start_datetime, format = "%H:%M:%OS")
sifaka.sched$start_time <- as.POSIXct(sifaka.sched$start_time, format = "%H:%M:%OS")
sifaka.sched$stop_time <- format(sifaka.sched$stop_datetime, format = "%H:%M:%OS")
sifaka.sched$stop_time <- as.POSIXct(sifaka.sched$stop_time, format = "%H:%M:%OS")
sifaka.sched <- arrange(sifaka.sched, animal, start_datetime)

#Separate 1Hz data points
high.res.sched <- filter(sifaka.sched, length_sec > 6 & animal != "Langur" & animal != "Mercury" & animal != "Nyx")
high.res.sched$start_time <- format(high.res.sched$start_datetime, format = "%H:%M:%OS")
high.res.sched$start_time <- as.POSIXct(high.res.sched$start_time, format = "%H:%M:%OS")
high.res.sched$stop_time <- format(high.res.sched$stop_datetime, format = "%H:%M:%OS")
high.res.sched$stop_time <- as.POSIXct(high.res.sched$stop_time, format = "%H:%M:%OS")
summary(high.res.sched)

#Separate overnight data points
overnight.sched <- filter(sifaka.sched, length_sec == 0 & animal != "Langur" & animal != "Mercury" & animal != "Nyx")
overnight.sched$start_time <- format(overnight.sched$start_datetime, format = "%H:%M:%OS")
overnight.sched$start_time <- as.POSIXct(overnight.sched$start_time, format = "%H:%M:%OS")
overnight.sched$stop_time <- format(overnight.sched$stop_datetime, format = "%H:%M:%OS")
overnight.sched$stop_time <- as.POSIXct(overnight.sched$stop_time, format = "%H:%M:%OS")
overnight.sched <- filter(overnight.sched, start_time <= as.POSIXct("06:30:00", format = "%H:%M:%OS") | start_time >= as.POSIXct("17:30:00", format = "%H:%M:%OS"))
overnight.sched <- filter(overnight.sched, stop_time <= as.POSIXct("06:30:00", format = "%H:%M:%OS") | stop_time >= as.POSIXct("17:30:00", format = "%H:%M:%OS"))
summary(overnight.sched)

#Separate regular/3min data points
regular.sched <- filter(sifaka.sched, !(fix_id %in% high.res.sched$fix_id) & !(fix_id %in% overnight.sched$fix_id))
regular.sched$start_time <- format(regular.sched$start_datetime, format = "%H:%M:%OS")
regular.sched$start_time <- as.POSIXct(regular.sched$start_time, format = "%H:%M:%OS")
regular.sched$stop_time <- format(regular.sched$stop_datetime, format = "%H:%M:%OS")
regular.sched$stop_time <- as.POSIXct(regular.sched$stop_time, format = "%H:%M:%OS")
summary(regular.sched)

#Separate TEST data points
test.sched <- filter(sched, species == "Homo sapiens")
test.sched$start_time <- format(test.sched$start_datetime, format = "%H:%M:%OS")
test.sched$start_time <- as.POSIXct(test.sched$start_time, format = "%H:%M:%OS")
test.sched$stop_time <- format(test.sched$stop_datetime, format = "%H:%M:%OS")
test.sched$stop_time <- as.POSIXct(test.sched$stop_time, format = "%H:%M:%OS")
summary(test.sched)

#Add deployment id to test

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Start
## Example 1 ####

write.csv(test.sched, 'input_add_tagid_to_test.csv', row.names = F, quote = F)

test.sched$deployment.id <- NA
pb <- txtProgressBar(min = 0, max = nrow(test.sched), style = 3)
for (i in 1:nrow(test.sched)) {
  options.i <- filter(reference, animal.id == "TEST" &
                        tag.id == test.sched$tag.local.identifier[i] &
                        local.deploy.on.date <= test.sched$start_datetime[i] &
                        local.deploy.off.date >= test.sched$stop_datetime[i])
  if (nrow(options.i) == 1) {
    test.sched$deployment.id[i] <- options.i$deployment.id
  }
  rm(options.i)
  setTxtProgressBar(pb, i)
}
close(pb)
rm(pb)
summary(as.factor(test.sched$deployment.id))

write.csv(test.sched, 'output_add_tagid_to_test.csv', row.names = F, quote = F)

## End
## Example 1 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#Separate fosa data points
fosa.sched <- filter(sched, species == "Cryptoprocta ferox")
fosa.sched$start_time <- format(fosa.sched$start_datetime, format = "%H:%M:%OS")
fosa.sched$start_time <- as.POSIXct(fosa.sched$start_time, format = "%H:%M:%OS")
fosa.sched$stop_time <- format(fosa.sched$stop_datetime, format = "%H:%M:%OS")
fosa.sched$stop_time <- as.POSIXct(fosa.sched$stop_time, format = "%H:%M:%OS")

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Start
## Example 2 #####

write.csv(sifaka.sched, 'input_add_time_lag.csv', row.names = F, quote = F)

#Add time lag to sifaka
sifaka.sched <- arrange(sifaka.sched, animal, start_datetime)
sifaka.sched$time_lag <- NA
for (i in 1:nrow(sifaka.sched)) {
  if (i != 1) {
    if (sifaka.sched$animal[i] == sifaka.sched$animal[i-1]) {
      sifaka.sched$time_lag[i] <- round(as.numeric(difftime(sifaka.sched$start_datetime[i],
                                                          sifaka.sched$start_datetime[i - 1], units = "mins")), digits = 0)
    }
  }
}
summary(sifaka.sched)

write.csv(sifaka.sched, 'output_add_time_lag.csv', row.names = F, quote = F)

## End
## Example 2 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#Add time lag to fosa
fosa.sched <- arrange(fosa.sched, animal, start_datetime)
fosa.sched$time_lag <- NA
for (i in 1:nrow(fosa.sched)) {
  if (i != 1) {
    if (fosa.sched$animal[i] == fosa.sched$animal[i-1]) {
      fosa.sched$time_lag[i] <- round(as.numeric(difftime(fosa.sched$start_datetime[i],
                                                          fosa.sched$start_datetime[i - 1], units = "mins")), digits = 0)
    }
  }
}
summary(fosa.sched)

#Check that all data is accounted for
nrow(sched) - (nrow(sifaka.sched) + nrow(test.sched) + nrow(fosa.sched))
nrow(sifaka.sched) - (nrow(high.res.sched) + nrow(overnight.sched) + nrow(regular.sched))


#Filter to create datasets
sifaka.data <- filter(GPS_data, fix_id %in% sifaka.sched$fix_id)
high.res.data <- filter(GPS_data, fix_id %in% high.res.sched$fix_id)
overnight.data <- filter(GPS_data, fix_id %in% overnight.sched$fix_id)
regular.data <- filter(GPS_data, fix_id %in% regular.sched$fix_id)
test.data <- filter(GPS_data, fix_id %in% test.sched$fix_id)
test.data <- left_join(test.data, test.sched[,c("fix_id", "deployment.id")], by = "fix_id")
fosa.data <- filter(GPS_data, fix_id %in% fosa.sched$fix_id)
fosa.data <- left_join(fosa.data, fosa.sched[,c("fix_id", "time_lag")], by = "fix_id")

#Check that all data is accounted for
nrow(GPS_data) - (nrow(sifaka.data) + nrow(test.data) + nrow(fosa.data))
nrow(sifaka.data) - (nrow(high.res.data) + nrow(overnight.data) + nrow(regular.data))


# Create sifaka three-min dataset ______________________________________________

#Keep latest fix in each GPS burst
keep <- list()
pb <- txtProgressBar(min = 0, max = nrow(regular.sched), style = 3)
for (i in 1:nrow(regular.sched)) {
  keep[[i]] <- which(regular.data$fix_id == regular.sched$fix_id[i] &
                       regular.data$fix_pos == regular.sched$num_fixes[i])
  setTxtProgressBar(pb, i)
}
close(pb)
rm(pb)
regular.keep <- regular.data[do.call(c, keep),]
rm(keep)

#Convert 1Hz data to regular data
# keep <- list()
# pb <- txtProgressBar(min = 0, max = nrow(high.res.sched), style = 3)
# for (i in 1:nrow(high.res.sched)) {
#   keep[[i]] <- which((high.res.data$study.local.timestamp %in%
#                         seq(from = (high.res.sched$start_datetime[i] + 6), to = high.res.sched$stop_datetime[i], by = 180)) &
#                        high.res.data$tag.local.identifier == high.res.sched$tag.local.identifier[i])
#   setTxtProgressBar(pb, i)
# }
# close(pb)
# rm(pb)
# high.res.keep <- high.res.data[do.call(c, keep),]
# rm(keep)
# 
# three.min.data <- rbind(regular.keep, high.res.keep)
# hist(three.min.data$timestamp, breaks = 100)


# Save ________________________________________________________________________

#Arrange all
GPS_data <- arrange(GPS_data, individual.taxon.canonical.name, individual.local.identifier, study.local.timestamp)
sifaka.data <- arrange(sifaka.data, individual.local.identifier, study.local.timestamp)
high.res.data <- arrange(high.res.data, individual.local.identifier, study.local.timestamp)
overnight.data <- arrange(overnight.data, individual.local.identifier, study.local.timestamp)
regular.data <- arrange(regular.data, individual.local.identifier, study.local.timestamp)
# three.min.data <- arrange(three.min.data, individual.local.identifier, study.local.timestamp)
fosa.data <- arrange(fosa.data, individual.local.identifier, study.local.timestamp)
test.data <- arrange(test.data, deployment.id, tag.local.identifier, study.local.timestamp)

sched <- arrange(sched, species, animal, start_datetime)
sifaka.sched <- arrange(sifaka.sched, animal, start_datetime)
high.res.sched <- arrange(high.res.sched, animal, start_datetime)
overnight.sched <- arrange(overnight.sched, animal, start_datetime)
regular.sched <- arrange(regular.sched, animal, start_datetime)
fosa.sched <- arrange(fosa.sched, animal, start_datetime)
test.sched <- arrange(test.sched, animal, start_datetime)

#Save _________________________________________________________________________
save(list = c("high.res.data", "high.res.sched",
              "overnight.data", "overnight.sched",
              "regular.data", "regular.sched"
#              ,"three.min.data"
      ),
     file = "02.cleaned_june_sifaka_data_divided.RData")

save(list = c("sifaka.data", "sifaka.sched"),
     file = "02.cleaned_june_sifaka_data.RData")

save(list = c("fosa.data", "fosa.sched"),
     file = "02.cleaned_june_fosa_data.RData")

save(list = c("test.data", "test.sched"),
     file = "02.cleaned_june_test_data.RData")

save(list = c("GPS_data", "sched"),
     file = "02.cleaned_june_data_all.RData")


