library(jsonlite)
library(data.table) # used for rbindlist

# Define Params

input_file <- 'data/eva-data.json'
output_csv <- 'results/eva_data.csv'
plot_file <- 'results/plot.png'

print("--START--")

# Read in Data ----
# Read the data from JSON file
print(paste("Reading JSON file", input_file))

eva_list <- jsonlite::read_json(input_file)
eva_data <- rbindlist(eva_list, use.names = TRUE, fill = TRUE)
eva_data$eva <- as.numeric(eva_data$eva)
eva_data$date <- as.POSIXct(eva_data$date)

# Data Cleaning ----
# Clean the data by removing any incomplete rows
eva_data <- eva_data[rowSums(is.na(eva_data)) == 0, ]

# Save CSV ----
print(paste("Saving to CSV file", output_csv))
# Save dataframe to CSV file for later analysis
write.csv(
  format.data.frame(eva_data, nsmall=1),
  output_csv, row.names = FALSE, quote = ncol(eva_data)
)

# Analysis ----
# Sort dataframe by date ready to be plotted (date values are on x-axis)
eva_data <- eva_data[order(eva_data$date), ]

# Add duration and cum duration in minutes
hours_minutes <- strsplit(eva_data$duration, ":") # results in list of length 2 vectors
for(i in seq_along(hours_minutes)) {
  eva_data[i, 'duration_hours'] <- as.numeric(hours_minutes[[i]][1]) + as.numeric(hours_minutes[[i]][2]) / 6
}

eva_data$cumulative_time <- cumsum(eva_data$duration_hours)

# Plotting ----
# Plot cumulative time spent in space over years
print(paste("Plotting cumulative spacewalk duration and saving to", plot_file))
plot(
  eva_data$date,
  eva_data$cumulative_time,
  xlab = "Year",
  ylab= "Minutes",
  main = "Total time spent in space to date"
)
dev.copy(png, plot_file)
dev.off()

print("--END--")