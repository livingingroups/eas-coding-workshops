library(rethinking)
library(dplyr)
library(RColorBrewer)
library(lubridate)

# 0. Options and Globals ----

options(cmdstanr_output_dir = './saved-models/sampling-output')

# 1. Functions ----

## 1.1 Workshop Specific functions ----

# This let's %>% work without loading all of dplyr
#`%>%` <- dplyr::`%>%`

# This lets us load a saved model instead of running it
# just for workshop purposes
fetch_saved_model <- function(...){
  name <- basename(list(...)[['file']])
  cat(readLines(file(
    file.path('saved-models', 'text-output', paste0(name, '-out.txt'))
  )), sep = '\n')
  readRDS(
    file.path('saved-models', paste0(name, '-model.rds'))
  )
}
stan <- fetch_saved_model

save_plot <- function(filename, ...){
  png(filename = filename)
  plot(...)
  dev.off()
  filename
}

## 1.2 Loading and initial processing functions----

#' Load Group Homerange Data 
#'
#' @param path to file output by Odd's ctmm pipeline
#'
#' @return data.frame of loaded data
#' @export
#'
load_group_homerange_data <- function(path){
  ## group size ----
  d_hr_gs <- read.csv(path)
  
  d_hr_gs$group_index <- as.integer(as.factor(d_hr_gs$group))
  d_hr_gs$group_size_std <- rethinking::standardize(d_hr_gs$group_size)
  return(d_hr_gs)
}

load_and_process_enso_data <- function(mei_path, d_hr_gs){
  mei <- dplyr::tibble(read.table(mei_path, sep = ',', header=TRUE, stringsAsFactors = TRUE))
  d_mei <- mei[mei$year >= min(d_hr_gs$year) - 1,]
  d_mei <- d_mei[complete.cases(d_mei),]
  d_mei$phase_index <- as.integer(d_mei$phase)
  return(d_mei)
}

load_riparian_data <- function(path){
  drip <- read.csv(path)
  drip <- drip[drip$year < 2020,]
  drip$group_index <- as.integer(as.factor(drip$group))
  return(drip)
}

## 1.3 validation functions----

validate_group_homerange_data <- function(d_hr_gs){
  d_hr_gs_check <- validate::confront(
    d_hr_gs,
    validate::validator(
      is.character(id),
      is.character(group),
      is.integer(X), # row number
      is.integer(year),
      is.integer(group_size),
      is.numeric(DOF),
      is.numeric(low),
      is.numeric(area),
      is.numeric(high),
      is.numeric(scale),
      is.numeric(rate),
      is.numeric(shape)
    ),
    raise = 'all'
  ) 
  if(any(summary(d_hr_gs_check)[, c("fails", "error")])) warning("Problem with group size data")
  return(d_hr_gs_check)
}

visually_check_enso <- function(d_mei){
  elcol_pal <- rev(RColorBrewer::brewer.pal(3 , "RdYlBu"))
  group_pal <- RColorBrewer::brewer.pal(11 , "Spectral")
  filenames <- c('plots/mei_check.png', 'plots/mei_check2.png')
  
  save_plot(filenames[1], mei~date, data=d_mei)
  
  png(filename = filenames[2])
  plot(d_mei$mei~d_mei$date , col=elcol_pal[d_mei$phase_index] , pch=19 , cex=0. , xlab="year" , ylab="MEI index")
  mei_spl <- with(d_mei, smooth.spline(date, mei))
  lines(mei_spl, col = "grey3")
  abline(v=d_mei$date[1:33] , col="grey")
  dev.off()
  
  return(filenames)
}

plot_rate_shapes <- function(d_hr_gs_3){
  # TODO: Reintegrate this code. Belongs basically inside construct_main_list
  # TODO: make this write to file instead of just opening the plot
  for(i in 10:20){
    plot(density(rgamma(10000,shape=d_hr_gs_3$shape[[i]], rate=d_hr_gs_3$rate[[i]] ) , xlim=c(0,10)) , main="blah" )
    lines(density(rgamma(10000,shape=d_hr_gs_3$shape[[i]], scale=d_hr_gs_3$scale[[i]] ) ) , lty=2 )
    points( d_hr_gs_3$area[i] , 0.1 )
    segments(  x0=d_hr_gs_3$low[i], y0=0.1 , x1=d_hr_gs_3$high[i] ,y1= 0.1 , col="blue")
  }
}


## 1.4 Major processing functions----

construct_riparian_list <- function(d_mei, d_hr_gs, drip) {
  ## combie data frames, will do posterior across time series later ---
  
  d_hr_gs_2 <- merge(d_hr_gs, d_mei , by="year")
  d_hr_gs_2 <- d_hr_gs_2[d_hr_gs_2$month=="JJ",]
  min(d_mei$year)
  d_mei$year_index_overall <- d_mei$year - 1989
  
  
  ## mei consolidate ---
  # TODO: add structure validation
  # str(d_hr_gs_2)
  mean_df <- aggregate(mei ~ year, d_mei, mean)
  names(mean_df)[2] <- "mean_annual_mei"
  max_df <- aggregate(mei ~ year, d_mei, max)
  names(max_df)[2] <- "max_annual_mei"
  min_df <- aggregate(mei ~ year, d_mei, min)
  names(min_df)[2] <- "min_annual_mei"
  sd_df <- aggregate(mei ~ year, d_mei, sd)
  names(sd_df)[2] <- "sd_annual_mei"
  
  ## compile bigger data frames ----
  
  d_mei <- d_mei %>%
    dplyr::mutate(date = as.Date(date, "%Y-%m-%d")) %>%
    dplyr::arrange(date)
  d_mei$year_analyze <- NA
  
  min(d_mei$date[d_mei$year==1991])
  
  ## make mei datasets ----
  
  ### compile bigger data frames ----
  pasta <- min(which(d_mei$year==1991))
  d_mei[pasta:(pasta+11),]
  
  # add wet and dry season to mei, 1st 4 months of year is dry
  d_mei$season <- ifelse( lubridate::month(d_mei$date) < 5 , "dry" , "wet" )
  d_mei$season_index <- as.integer(as.factor(d_mei$season))
  drip$year_index <- as.integer(as.factor(drip$year))
  
  d_mei_hr_data_2 <- d_mei[is.element(d_mei$year , drip$year),]
  
  # TODO: extract and/or formalize this check
  #str(d_mei_hr_data_2)
  
  d_mei_hr_data_2 <- d_mei_hr_data_2[d_mei_hr_data_2$year < 2020,]
  drip <- merge(drip,d_hr_gs[,c(2,12,14)],by="id") 
  
  ##riparian data list
  list_rip <- list(
    hr_area=round(drip$hr_area),
    intersect_area=round(drip$intersect_area) ,
    prop_river=drip$prop_river ,
    group_index=drip$group_index ,
    # group_size=drip$group_size ,
    year_index=as.integer(as.factor(drip$year)),
    year=as.integer(drip$year),
    mei=d_mei_hr_data_2$mei,
    year_index_mei=as.integer(as.factor(d_mei_hr_data_2$year)),
    N_years=length(unique(d_mei_hr_data_2$year)),
    N=nrow(drip) ,
    N_groups=length(unique(drip$group_index)),
    group_size_std=drip$group_size_std ,
    group_size=drip$group_size
  )
  # TODO: add structure validation
  # str(list_rip)
  return(list_rip)
}

construct_main_list <- function(d_mei, d_hr_gs) {
  elcol_pal <- rev(RColorBrewer::brewer.pal(3 , "RdYlBu"))
  group_pal <- RColorBrewer::brewer.pal(11 , "Spectral")
  
  
  d_hr_gs_2 <- merge(d_hr_gs, d_mei , by="year")
  d_hr_gs_2 <- d_hr_gs_2[d_hr_gs_2$month=="JJ",]
  min(d_mei$year)
  d_mei$year_index_overall <- d_mei$year - 1990
  
  ### mei consolidate ----
  # TODO: add structure validation
  #str(d_hr_gs_2)
  mean_df <- aggregate(mei ~ year, d_mei, mean)
  names(mean_df)[2] <- "mean_annual_mei"
  max_df <- aggregate(mei ~ year, d_mei, max)
  names(max_df)[2] <- "max_annual_mei"
  min_df <- aggregate(mei ~ year, d_mei, min)
  names(min_df)[2] <- "min_annual_mei"
  sd_df <- aggregate(mei ~ year, d_mei, sd)
  names(sd_df)[2] <- "sd_annual_mei"
  
  ### compile bigger data frames ----
  
  d_hr_gs_3 <- merge(d_hr_gs, mean_df , by="year")
  d_hr_gs_3 <- merge(d_hr_gs_3, min_df , by="year")
  d_hr_gs_3 <- merge(d_hr_gs_3, max_df , by="year")
  d_hr_gs_3 <- merge(d_hr_gs_3, sd_df , by="year")
  #d_hr_gs_3 <- merge(d_hr_gs_3, d_akde , by="id")
  
  d_hr_gs_3$year_index <- as.integer(as.factor(d_hr_gs_3$year))
  d_mei_hr_data <- d_mei[is.element(d_mei$year , d_hr_gs_3$year),]
  
  # TODO add structure validation
  #str(d_hr_gs_3)
  
  # add columns
  d_hr_gs_3$hr_area_mean <- d_hr_gs_3$area
  d_hr_gs_3$hr_area_low <- d_hr_gs_3$low
  d_hr_gs_3$hr_area_high <- d_hr_gs_3$high
  d_hr_gs_3$group_index <- as.integer(as.factor(d_hr_gs_3$group))
  d_hr_gs_3$group_size_std <- rethinking::standardize(d_hr_gs_3$group_size)
  
  
  list_area <- list(
    hr_area_mean=d_hr_gs_3$hr_area_mean ,
    hr_area_high=d_hr_gs_3$hr_area_high ,
    hr_area_low=d_hr_gs_3$hr_area_low ,
    mean_annual_mei=d_hr_gs_3$mean_annual_mei ,
    min_annual_mei=d_hr_gs_3$min_annual_mei ,
    max_annual_mei=d_hr_gs_3$max_annual_mei ,
    sd_annual_mei=d_hr_gs_3$sd_annual_mei ,
    group_index=d_hr_gs_3$group_index ,
    group_size=d_hr_gs_3$group_size_std ,
    year_index=d_hr_gs_3$year_index 
  )
  
  list_area_2 <- list(
    hr_area_mean=d_hr_gs_3$hr_area_mean ,
    hr_area_high=d_hr_gs_3$hr_area_high ,
    hr_area_low=d_hr_gs_3$hr_area_low ,
    #hr_area_sd=d_hr_gs_3$hr_area_sd ,
    hr_area_rate=d_hr_gs_3$rate ,
    hr_area_shape=d_hr_gs_3$shape ,
    group_index=d_hr_gs_3$group_index ,
    group_size=d_hr_gs_3$group_size ,
    group_size_std=d_hr_gs_3$group_size_std ,
    log_group_size=log(d_hr_gs_3$group_size) ,
    year_index=d_hr_gs_3$year_index,
    mei=d_mei_hr_data$mei ,
    year_mei=d_mei_hr_data$year ,
    year_index_mei=as.integer(as.factor(d_mei_hr_data$year)),
    N_years=length(unique(d_mei_hr_data$year)),
    N=nrow(d_hr_gs_3) ,
    N_groups=length(unique(d_hr_gs_3$group_index)) ,
    mean_annual_mei=d_hr_gs_3$mean_annual_mei ,
    min_annual_mei=d_hr_gs_3$min_annual_mei ,
    max_annual_mei=d_hr_gs_3$max_annual_mei ,
    sd_annual_mei=d_hr_gs_3$sd_annual_mei ,
    kde_shape=d_hr_gs_3$shape ,
    kde_rate=d_hr_gs_3$rate ,
    kde_scale=d_hr_gs_3$scale ,
    phase_index=d_mei_hr_data$phase_index,
    N_mei = length(d_mei_hr_data$mei)
  )
  return(list_area_2)
}

calculate_area_log <- function(list_area_2){
  ## home range on log scale, is same as if you don't log it does not matter
  list_area_2_log <- list_area_2
  list_area_2_log$group_size <-  list_area_2_log$log_group_size
  return(list_area_2_log)
}

## 1.5 Modeling Functions ----

run_a_model <- function(file, data, seed) {
  stan(
    file = file,
    data = data,
    seed = seed,
    iter = 4000,
    chains = 4,
    cores = 4,
    control = list(adapt_delta = 0.99),
    refresh = 250,
    init = 0,
    rstan_out = FALSE
  )
}

run_models <- function(list_area_2, list_area_2_log, list_rip) {
  elcol_pal <- rev(RColorBrewer::brewer.pal(3 , "RdYlBu"))
  group_pal <- RColorBrewer::brewer.pal(11 , "Spectral")
  
  ## run models ---
  
  rethinking::set_ulam_cmdstan(TRUE)
  
  fits <- list(
    test = run_a_model(
      file = 'stan_code/test_mei.stan',
      data = list_area_2,
      seed = 12
    ),
    mei_hr = run_a_model(
      file = 'stan_code/mei_hr.stan',
      data = list_area_2,
      seed=232
    ),
    hr_meas = run_a_model(
      file = 'stan_code/hr_meas.stan',
      data = list_area_2,
      seed=813
    ),
    hr_meas_varef = run_a_model( 
      file = 'stan_code/hr_meas_varef.stan',
      data = list_area_2,
      seed=813
    ),
    # used in
    hr_mei_meas_er = run_a_model(
      file = 'stan_code/hr_mei_meas_er.stan',
      data = list_area_2,
      seed=3169
    ), 
    # main result
    hr_mei_gs_meas_er = run_a_model(
      file = 'stan_code/hr_mei_gs_meas_er.stan',
      data = list_area_2,
      seed=169
    ),
    # home range only
    hr_gs_meas_er = run_a_model(
      file = 'stan_code/hr_gs_meas_er.stan',
      data = list_area_2,
      seed=169
    ),
    hr_loggs_meas_er = run_a_model(
      file = 'stan_code/hr_gs_meas_er.stan',
      data = list_area_2_log,
      seed=169
    ),
    mei_rip = run_a_model(
      file = 'stan_code/rip_mei_meas_er.stan', #stupid name
      data = list_rip,
      seed=1239
    )
  )
  
  return(fits)
}

examine_models <- function(fits){
  # TODO: probably want to print and/or return all this, not just run it
  
  rethinking::precis(fits[['test']] , depth=2)
  
  rethinking::precis(fits[['mei_hr']], depth=2)
  
  ##### hr shape scale ----
  
  rethinking::precis(fits[['hr_post']] , depth=2)
  
  rethinking::precis(fits[['hr_meas_varef']], depth=2)
  
  #### model used in supplement ----
  
  rethinking::precis(fits[['hr_mei_meas_er']], depth=2 , c("sigma_g"))
  post_hrgsmei <- rethinking::extract.samples(fits[['hr_mei_meas_er']])
  #precis(fit_hr, depth=2 , pars=c("sigma_g"))
  
  ### model used in main result -----
  rethinking::precis(fits[['hr_mei_gs_meas_er']], depth=2 , c("v_mu" ))
  rethinking::precis(fits[['hr_mei_gs_meas_er']], depth=2 , c("v_mu" , "sigma_g"))
  rethinking::precis(fits[['hr_mei_gs_meas_er']], depth=3, c("Rho_g") )
  
  ### home range only ----
  
  rethinking::precis(fits[['hr_gs_meas_er']], depth=2 , pars=c("v_mu" , "sigma_g" , "k") )
  post_hrgs <- rethinking::extract.samples(fits[['hr_gs_meas_er']])
  
  ###  log scale ----
  
  rethinking::precis(fits[['hr_loggs_meas_er']], depth=2 , pars=c("v_mu" , "sigma_g" , "k") )
  
  post_hrgs <- extract.samples(fits[['hr_gs_meas_er']])
  
  post_meirip <- extract.samples(fits[['mei_rip']])
  rethinking::precis(fits[['mei_rip']], depth=2)
  rethinking::precis(fits[['mei_rip']], depth=3 , pars="v")
  rethinking::precis(fits[['mei_rip']], depth=3 , pars="Rho_g")
}
