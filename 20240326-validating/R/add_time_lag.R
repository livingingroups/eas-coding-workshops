library(tidyverse)

add_time_lag <- function(sifaka.sched){
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
  return(sifaka.sched)
}