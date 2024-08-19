library(raster)
library(terra)
library(tmap)
library(tidyverse)
library(sf)
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
        "binary_comparison.tif"
      )
    )
  }else {
    mop <- raster(
      paste0(
        path_cal,
        "/MOP_agremment_kuenm/Set_1/MOP_10%_60_", scenario, "_agreement.tif"
      )
    )
    
    proj_changes <- raster(
      paste0(
        path_cal,
        "/Projection_Changes/Changes_EC/Period_1/Scenario_", scenario, "_60/",
        "binary_comparison.tif"
      )
    )
  }

  # next_part ---------------------------------------------------------------

  crs(mop) <- crs(proj_changes)

  proje_changes_cropped <-
    crop(proj_changes, extent(mop))

  mop[mop > 0] <-NA

  suit_non_risk <-
    mask(proje_changes_cropped, mop)

  layer_list <- c(layer_list, suit_non_risk)
}

shapefile <- st_read("data/raw/raster/Neotropic/Neotropic.shp")

layer_list <- stack(layer_list)

# Crie um tema para o tmap
my_theme <- tm_layout(frame = FALSE)

list_sp <- gsub("_", " ", list_sp)

cores <- c("#CCCCCC", "#FFFF99",  "#FFD700","#4B0082","#DDA0DD","#ADD8E6")

# Criar o mapa com tmap
proj_changes <- tm_shape(layer_list) +
  tm_raster(style = "cat", palette = cores, title = "Proj \n Changes") +
  tm_shape(shapefile) +
  tm_borders(col = "black", lwd = 1)+
  tm_layout(
    legend.outside = FALSE, 
    legend.text.size = 0.4, 
    panel.labels = list_sp,
    legend.position = c("LEFT", "CENTER"),
    legend.frame = FALSE, 
    outer.margins = c(0.00000001, 0.00000001, 0.00000001, 0.00000001),
    inner.margins = c(0.1, 0.1, 0.1, 0.1)) +
  tm_compass(type = "4star", size = 2, position = c("RIGHT", "TOP")) +
  tm_scalebar(text.size = 0.5, position = c("LEFT", "BOTTOM"))

# Mostrar o mapa
proj_changes

tmap_save(proj_changes, paste0("outputs/proj_changes_with_mop_", scenario, "_", subgenus, ".svg"), dpi= 600, height=10, width=10)

