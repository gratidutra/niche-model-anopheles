source("src/utils/functions.R")
source("src/utils/libraries.R")

data <- read_excel('data/selected_variables.xlsx') %>% 
  mutate(across(2:6, char_to_list, .names = "{.col}")) 

species_list <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_apicimacula",
  "Anopheles_aquasalis", "Anopheles_argyritarsis", "Anopheles_braziliensis",
  "Anopheles_darlingi", "Anopheles_eiseni", "Anopheles_evansae", "Anopheles_intermedius",
  "Anopheles_mediopunctatus", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_peryassui", "Anopheles_pseudopunctipennis", "Anopheles_punctimacula",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)

buffer_area_list <- c(100, 200, 250, 300, 400, 500)

for (specie in seq_along(species_list)) {
  for (km in seq_along(buffer_area_list)) {
    # Buffer Area -------------------------------------------------------------
    sp_name <- species_list[[specie]]
    path_workflow <- paste0("data/workflow_maxent/", sp_name)
    km <- buffer_area_list[[km]]
    path_cal <- paste0(path_workflow, "/km_", km)

    # low corr
    
    loc_variables <- data %>%
    dplyr::filter(species == sp_name) %>%
    dplyr::select(km)

    flat_list <- as.numeric(unlist(loc_variables[[1]]))

    # Workflow Kuenm -> Model Calibration -------------------------------------

    dir_create(
      paste0(
        path_cal,
        "/Model_calibration"
      )
    )

    dir_create(
      paste0(
        path_cal, "/Model_calibration/M_variables"
      )
    )

    dir_create(
      paste0(
        path_cal, "/Model_calibration/M_variables/Set_1"
      )
    )

    file.copy(
      from = paste0(path_cal, "/Calibration_area_", km, "/bio", flat_list, ".asc"),
      to = paste0(path_cal, "/Model_calibration/M_variables/Set_1/bio", flat_list, ".asc"),
      overwrite = T
    )

    # #------------------Principal component analysis and projections-----------------

    layers_list <-
      c(
        "Current",
        "future_layer_can_126_60", "future_layer_can_585_60",
        "future_layer_mc_126_60", "future_layer_mc_585_60"
      )

    # PCA and projections
    dir_create(paste0(path_cal, "/pcas"))
    dir_create(paste0(path_cal, "/pcas/pca_", km))
    dir_create(paste0(path_cal, "/pcas/pca_", km, "/pca_referenceLayers"))
    dir_create(paste0(path_cal, "/pcas/pca_", km, "/pca_proj"))

    # dir_create(paste0("G_Variables/Set_2"))

    for (layer in seq_along(layers_list)) {
      do_pca(
        set = 2,
        time = layers_list[[layer]],
        path_layer_stack = paste0(path_cal, "/Calibration_area_", km),
        #path_layer_proj = NULL,
        path_layer_proj = paste0("data/bioclim_layer/CMIP6/", layers_list[[layer]]),
        sv_dir = paste0(path_cal, "/pcas/pca_", km, "/", layers_list[[layer]]),
        #sv_proj_dir = NULL,
        sv_proj_dir = paste0(path_cal,"/pcas/pca_", km, "/pca_proj_", layers_list[[layer]]),
        nums = 1:5,
        m_dir = paste0(path_cal, "/Model_calibration/M_variables/Set_2"),
        #m_dir = NULL,
        g_dir = paste0(path_cal, "/G_variables/Set_2"),
        from_proj = TRUE
      )
    }
  }
}
