source('./03-three-file-workflow/spatial_enso_lomas_lib.R')

VISUAL_CHECKS <- TRUE

group_data <- load_group_homerange_data(path = "data/df_slpHRarea_group_size.csv")
group_validation <- validate_group_homerange_data(group_data)
if(VISUAL_CHECKS){
  plot(group_validation)
  print(str(group_data))
}

mei_data <- load_and_process_enso_data('data/mei.csv', group_data)
# TODO: add formal validation in addition to plots checks
if(VISUAL_CHECKS) visually_check_enso(mei_data)

riparian_data <- load_riparian_data("data/df_annual_riparian.csv")
if(VISUAL_CHECKS) str(riparian_data)

## process data ----

riparian_list <- construct_riparian_list(mei_data, group_data, riparian_data)
area_list <- construct_main_list(mei_data, group_data)
area_list_log <- calculate_area_log(area_list)

## run model ----
fits <- run_models(area_list, area_list_log, riparian_list)
examine_models(fits)