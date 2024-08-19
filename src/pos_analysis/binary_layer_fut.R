library(raster)
library(terra)
library(tmap)
library(tidyverse)
library(dichromat)
library(sf)
library(ntbox)

list_sp <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_aquasalis",
  "Anopheles_braziliensis", "Anopheles_darlingi", "Anopheles_evansae", "Anopheles_nuneztovari", 
  "Anopheles_oswaldoi", "Anopheles_strodei", "Anopheles_triannulatus", "Anopheles_apicimacula", 
  "Anopheles_eiseni","Anopheles_intermedius", "Anopheles_mediopunctatus",
  "Anopheles_peryassui", "Anopheles_pseudopunctipennis", "Anopheles_punctimacula"
)

layer_list <- list()

# subgenus <- "ny"

shapefile <- st_read("data/raw/raster/Neotropic/Neotropic.shp")

layer_list <- list()

scenario <- "126"

for (specie in seq_along(list_sp)) {
  sp_name <- list_sp[[specie]]
  
  # if (sp_name %in% c("Anopheles_oswaldoi", "Anopheles_peryassui")) {
  #   km <- "/km_200/"
  # } else {
  #   km <- "/km_250/"
  # }
  
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
    mop <- raster(
      paste0(
        path_cal,
        "/MOP_agremment_kuenm/Set_2/MOP_10%_60_", scenario, "_agreement.tif"
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
  } else {
    mop <- raster(
      paste0(
        path_cal,
        "/MOP_agremment_kuenm/Set_1/MOP_10%_60_", scenario, "_agreement.tif"
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
  }
  
  agree_ogcm <- raster::mosaic(ogcm_1, ogcm_2, fun = mean)
  
  # next_part ---------------------------------------------------------------
  
  crs(mop) <- crs(agree_ogcm)
  
  ogcm_cropped <-
    crop(agree_ogcm, extent(mop))
  
  mop[mop > 0] <- NA
  
  suit_non_risk <-
    mask(ogcm_cropped, mop)
  
  data <- 
    read.csv(
    paste0(
      getwd(),
      "/data/workflow_maxent/", sp_name, "/", sp_name, "_joint.csv"
    )
  )
  
  binary <-
    bin_model(suit_non_risk, data[2:3], percent = 47.3)
  
  layer_list <- c(layer_list, binary)
}

spat_raster_list <-
  lapply(layer_list, rast)

rsrc <-
  sprc(spat_raster_list)

richness <-
  mosaic(rsrc, fun = "sum")

# plot(richness)

redblue <-
  colorRampPalette(c("#FFFFFF", "#3BBF67", "#9C7B7B", "#A36262", "#BA0F0F"))

binary <- tm_shape(richness) +
  tm_raster(style = "cont", palette = redblue(19), title = "Richness") +
  tm_shape(shapefile) +
  tm_borders(col = "black", lwd = 1) +
  tm_layout(
    # legend.outside = FALSE,
    # legend.text.size = 0.4,
    panel.labels = "B- SSP1-2.6",
    panel.label.size = 4,
    # legend.position = c("LEFT", "CENTER"),
    # legend.frame = FALSE,
    outer.margins = c(0.00000001, 0.00000001, 0.00000001, 0.00000001),
    inner.margins = c(0.1, 0.1, 0.1, 0.1)
  ) +
  tm_compass(type = "4star", size = 2, position = c("RIGHT", "TOP")) +
  tm_scale_bar(text.size = 1, position = c("LEFT", "BOTTOM"))

binary

tmap_save(binary, paste0("outputs/richness/richness", scenario, ".svg"),
          dpi = 600, height = 10, width = 10
)

tmap_save(binary, paste0("outputs/richness/richness", scenario, ".jpg"),
          dpi = 600, height = 10, width = 10
)
