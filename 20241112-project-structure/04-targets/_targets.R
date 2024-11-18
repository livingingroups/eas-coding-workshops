library(targets)

# Set target options:
tar_option_set(
  packages = c('rethinking', 'dplyr', 'RColorBrewer', 'lubridate')
)

# Source R
# this works if working directory is eas-coding-workshops/20241112-project-structure
# if working directory is '04-targets', only `tar_source()` is needed
tar_source('04-targets/R')

# Define targets
list(
  
  ## settings ----
  tar_target(VISUAL_CHECKS, TRUE),
  
  ## load and validate data ----
  tar_target(group_data, load_group_homerange_data(path = "data/df_slpHRarea_group_size.csv")),
  tar_target(group_visual_validation, if(VISUAL_CHECKS) save_plot('plots/groups_validation.png', group_validation), format='file'),
  tar_target(group_output_validation, if(VISUAL_CHECKS) str(group_data)),
  tar_target(group_validation, validate_group_homerange_data(group_data)),
  
  tar_target(mei_data, load_and_process_enso_data('data/mei.csv', group_data)),
  tar_target(enso_visual_validation, if(VISUAL_CHECKS) visually_check_enso(mei_data), format='file'),
  tar_target(enso_output_validation, if(VISUAL_CHECKS) str(mei_data)),
  
  tar_target(riparian_data, load_riparian_data("data/df_annual_riparian.csv")),
  tar_target(riparian_output_validation, if(VISUAL_CHECKS) str(riparian_data)),

  ## process data ----
  tar_target(riparian_list, construct_riparian_list(mei_data, group_data, riparian_data)),
  tar_target(area_list, construct_main_list(mei_data, group_data)),
  tar_target(area_list_log, calculate_area_log(area_list)),
  
  ## run model ----
  tar_target(fits, run_models(area_list, area_list_log, riparian_list)),
  tar_target(fits_visual_validation, examine_models(fits))
)
