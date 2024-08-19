library(ntbox)
library(raster)
library(terra)
library(tidyverse)
library(tmap)
library(sf)

sp <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_aquasalis",
  "Anopheles_argyritarsis", "Anopheles_braziliensis", "Anopheles_darlingi",
  "Anopheles_evansae", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_strodei", "Anopheles_triannulatus", "Anopheles_apicimacula", 
  "Anopheles_eiseni","Anopheles_intermedius", "Anopheles_mediopunctatus",
  "Anopheles_peryassui", "Anopheles_pseudopunctipennis", "Anopheles_punctimacula"
)

layer_list <- list()

list_sp <- sp

# subgenus <- "ny"

scenario <- "Current"

shapefile <- st_read("data/raw/raster/Neotropic/Neotropic.shp")

for (specie in seq_along(list_sp)) {
  sp_name <- list_sp[[specie]]
  # selected_model <- read.csv('data/selected_models_1.csv') %>%
  #   dplyr::filter(species == sp_name) %>%
  #   dplyr::select(best_model)

  # selected_model[[1]] <-  gsub(" ", "_", as.factor(selected_model[[1]]))
  path_cal <- paste0("data/workflow_maxent/", sp_name, "/km_250/")

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
        "/MOP_results/Set_2/MOP_10%_", scenario, ".tif"
      )
    )
  } else {
    mop <- raster(
      paste0(
        path_cal,
        "/MOP_results/Set_1/MOP_10%_", scenario, ".tif"
      )
    )
  }

  layer <- raster(
    paste0(
      path_cal, "Final_models/", model[[1]], "_EC/", sp_name, "_",
      "Current_median.asc"
    )
  )

  crs(mop) <- crs(layer)

  ogcm_cropped <-
    crop(layer, extent(mop))

  mop[mop == 0] <- NA

  suit_non_risk <-
    mask(ogcm_cropped, mop)

  # layer_list <- c(layer_list, suit_non_risk)

  data <- read.csv(
    paste0(
      getwd(),
      "/data/workflow_maxent/", sp_name, "/", sp_name, "_joint.csv"
    )
  )

  binary <-
    bin_model(suit_non_risk, data[2:3], percent = 47.9)

  layer_list <- c(layer_list, binary)
}

# plot(stack(layer_list))

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
  tm_raster(style = "cont", palette = redblue(19), title = "Riqueza") +
  tm_shape(shapefile) +
  tm_borders(col = "black", lwd = 1) +
  tm_layout(
    # legend.outside = FALSE,
    # legend.text.size = 0.4,
    panel.labels = "A- Presente",
    panel.label.size = 4,
    # legend.position = c("LEFT", "CENTER"),
    # legend.frame = FALSE,
    outer.margins = c(0.00000001, 0.00000001, 0.00000001, 0.00000001),
    inner.margins = c(0.1, 0.1, 0.1, 0.1)
  ) +
  tm_compass(type = "4star", size = 3, position = c("RIGHT", "TOP")) +
  tm_scale_bar(text.size = 1, position = c("LEFT", "BOTTOM"))

binary

tmap_save(binary, paste0("outputs/richness/richness", scenario, ".svg"),
  dpi = 600, height = 8, width = 10
)

tmap_save(binary, paste0("outputs/richness/richness", scenario, ".jpg"),
          dpi = 600, height = 10, width = 10
)
