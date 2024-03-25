library(tidyverse)

add_deployment_id <- function(test.sched, reference){
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
  return(test.sched)
}