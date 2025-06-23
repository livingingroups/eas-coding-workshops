find_eco_cars <- function(car_df, threshold = 30){
  eco_cars <- c()
  for(i in 1:nrow(car_df)){
    if(car_df$mpg[i] > threshold){
      eco_cars <- c(eco_cars, rownames(car_df[i,]))
    }
  }
  return(eco_cars)
}

print(find_eco_cars(mtcars))