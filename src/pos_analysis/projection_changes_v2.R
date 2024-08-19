library(raster)
library(terra)
library(tmap)
library(tidyverse)
library(dichromat)

ny <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_aquasalis",
  "Anopheles_argyritarsis", "Anopheles_braziliensis", "Anopheles_darlingi",
  "Anopheles_evansae", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)

an <- c(
  "Anopheles_apicimacula", "Anopheles_eiseni", "Anopheles_intermedius",
  "Anopheles_mediopunctatus", "Anopheles_peryassui", "Anopheles_pseudopunctipennis",
  "Anopheles_punctimacula"
)

layer_list <- list()

list_sp <- ny

subgenus <- "ny"

scenario <- "126"

for (specie in seq_along(list_sp)) {
  sp_name <- list_sp[[specie]]

  path_cal <- paste0(
    getwd(),
    "/data/workflow_maxent/",
    sp_name, "/km_250/"
  )

  model <-
    read.csv(
      paste0(
        path_cal, "Final_Models_evaluation/fm_evaluation_results.csv"
      )
    ) %>%
    dplyr::slice(1) %>%
    dplyr::select(Model)

  if (sp_name %in% c("Anopheles_albimanus", "Anopheles_nuneztovari")) {
    current_suitability <- raster(
      paste0(
        path_cal, "Final_models/", model[[1]], "_EC/", sp_name, "_",
        "Current_median.asc"
      )
    )

    mop <- raster(
      paste0(
        path_cal,
        "/MOP_agremment_kuenm/Set_2/MOP_10%_60_", scenario, "_agreement.tif"
      )
    )

    proj_changes <- raster(
      paste0(
        path_cal,
        "/Projection_Changes/Changes_EC/Period_1/Scenario_", scenario, "_60/",
        "continuous_comparison.tif"
      )
    )
    
    proj_changes <- raster(
      paste0(
        path_cal,
        "/Projection_Changes/Changes_EC/Period_1/Scenario_", scenario, "_60/",
        "continuous_comparison.tif"
      )
    )
    
    ogcm_1 <- raster(
      paste0(
        path_cal,
        "Final_models/", model[[1]], "_EC/", sp_name, "_",
        "future_layer_can_", scenario, "_60_median.asc"
      )
    )
    
    ogcm_2 <- raster(
      paste0(
        path_cal,
        "Final_models/", model[[1]], "_EC/", sp_name, "_",
        "future_layer_mc_", scenario, "_60_median.asc"
      )
    )
    
    crs(mop) <- crs(current_suitability)
    crs(proj_changes) <- crs(current_suitability)
    crs(ogcm_1) <- crs(current_suitability)
    crs(ogcm_2) <- crs(current_suitability)

    common_extent <- 
      intersect(
        intersect(intersect(intersect(
          extent(mop), extent(current_suitability)), 
          extent(proj_changes)), 
          extent(ogcm_1)), 
        extent(ogcm_1))
    
    mop_cropped <-
      crop(mop, common_extent)

    anopheles_cropped <-
      crop(current_suitability, common_extent)

    comparison_cropped <-
      crop(proj_changes, common_extent)
    
    ogcm_1_cropped <-
      crop(ogcm_1, common_extent)
    
    ogcm_2_cropped <-
      crop(ogcm_2, common_extent)

    mop_resampled <-
      resample(mop_cropped, anopheles_cropped, method = "bilinear")

    comparison_resampled <-
      resample(comparison_cropped, anopheles_cropped, method = "bilinear")
    
    ogcm_1_resampled <-
      resample(ogcm_1_cropped, anopheles_cropped, method = "bilinear")
    
    ogcm_2_resampled <-
      resample(ogcm_2_cropped, anopheles_cropped, method = "bilinear")

    layer_result <-
   (mop_resampled < 1) &
     (anopheles_cropped > 0.6 &
       comparison_resampled > 0) |
     (anopheles_cropped < 0.6 &
       comparison_resampled > 0 &
       (ogcm_1_resampled >= 0.6 | ogcm_2_resampled >= 0.6))
    
  } else {
    current_suitability <- raster(
      paste0(
        path_cal, "Final_models/", model[[1]], "_EC/", sp_name, "_",
        "Current_median.asc"
      )
    )

    mop  <- raster(
      paste0(
        path_cal,
        "/MOP_agremment_kuenm/Set_1/MOP_10%_60_", scenario, "_agreement.tif"
      )
    )
    proj_changes <- raster(
      paste0(
        path_cal,
        "/Projection_Changes/Changes_EC/Period_1/Scenario_", scenario, "_60/",
        "continuous_comparison.tif"
      )
    )
    
    ogcm_1 <- raster(
      paste0(
        path_cal,
        "Final_models/", model[[1]], "_EC/", sp_name, "_",
        "future_layer_can_", scenario, "_60_median.asc"
      )
    )
    
    ogcm_2 <- raster(
      paste0(
        path_cal,
        "Final_models/", model[[1]], "_EC/", sp_name, "_",
        "future_layer_mc_", scenario, "_60_median.asc"
      )
    )

    crs(mop) <- crs(current_suitability)
    crs(proj_changes) <- crs(current_suitability)

    common_extent <-
      intersect(
        extent(mop),
        intersect(extent(current_suitability), extent(proj_changes))
      )
    mop_cropped <-
      crop(mop, common_extent)

    anopheles_cropped <-
      crop(current_suitability, common_extent)

    comparison_cropped <-
      crop(proj_changes, common_extent)

    mop_resampled <-
      resample(mop_cropped, anopheles_cropped, method = "bilinear")

    comparison_resampled <-
      resample(comparison_cropped, anopheles_cropped, method = "bilinear")
    
    layer_result <-
      (mop_resampled < 1) &
        (anopheles_cropped > 0.6) &
        (comparison_resampled < 0)
  }

  layer_list <- c(layer_list, layer_result)
  print(layer_list)
}

# Defina as cores para cada categoria
layer_list <- stack(layer_list)

# Defina as cores para cada categoria
cores <- c("gray", "red")

# Crie um tema para o tmap
my_theme <- tm_layout(frame = FALSE)

list_sp <- gsub("_", " ", list_sp)

# Plote o raster categórico com a paleta de cores definida
proj_changes <- tm_shape(layer_result) +
  tm_raster(col.scale = tm_scale_categorical(values = cores)) +
  tm_layout(
    legend.outside = FALSE,
    legend.text.size = 0.5,
    legend.position = c("LEFT", "CENTER"),
    panel.labels = list_sp,
    legend.frame = FALSE,
    outer.margins = c(0.00000001, 0.00000001, 0.00000001, 0.00000001),
    inner.margins = c(0.1, 0.1, 0.1, 0.1)
  ) +
  tm_compass(type = "4star", size = 1, position = c("RIGHT", "TOP")) +
  tm_scalebar(text.size = 0.6, position = c("LEFT", "BOTTOM"))


proj_changes
