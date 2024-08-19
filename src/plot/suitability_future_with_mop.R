library(raster)
library(terra)
library(tmap)
library(tidyverse)
library(dichromat)
library(sf)

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

shapefile <- st_read("data/raw/raster/Neotropic/Neotropic.shp")

layer_list <- list()

list_sp <- ny

subgenus <- "ny"

scenario <- "585"

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
    agree_ogcm <- raster::mosaic(ogcm_1, ogcm_2, fun = mean)
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
    agree_ogcm <- raster::mosaic(ogcm_1, ogcm_2, fun = mean)
  }
  

  # next_part ---------------------------------------------------------------

  crs(mop) <- crs(agree_ogcm)

  ogcm_cropped <-
    crop(agree_ogcm, extent(mop))

  mop[mop > 0] <- NA

  suit_non_risk <-
    mask(ogcm_cropped, mop)

  layer_list <- c(layer_list, suit_non_risk)
}

layer_list <- stack(layer_list)

# Crie um tema para o tmap
my_theme <- tm_layout(frame = FALSE)

# Crie um tema para o tmap
list_sp <- gsub("_", " ", list_sp)

letters <- LETTERS[1:length(list_sp)]

list_sp <- paste0(letters, "- ", list_sp)

# cores <- colorRampPalette(c("#CCCCCC", "#FFFF99",  "#FFD700","#4B0082","#DDA0DD","#ADD8E6"))

redblue <- colorRampPalette(c("#C6E0F9", "#294766", "#68e82c", "yellow", "red"))
#redblue <- colorRampPalette(c("#C6E0F9", "#294766"))

# Criar o mapa com tmap
suit_fut <- tm_shape(layer_list) +
  tm_raster(style = "cont", palette = redblue(15), title = "Adeq.") +
  tm_shape(shapefile) +
  tm_borders(col = "black", lwd = 1) +
  tm_layout(
    legend.outside = FALSE,
    legend.text.size = 0.4,
    panel.labels = list_sp,
    panel.label.fontface = "italic",
    legend.position = c("LEFT", "CENTER"),
    legend.frame = FALSE,
    outer.margins = c(0.00000001, 0.00000001, 0.00000001, 0.00000001),
    inner.margins = c(0.12, 0.12, 0.12, 0.12)
  ) +
  tm_add_legend(
    type = "polygons",
    labels = manual_labels,
    colors = manual_palette,
    position = c("LEFT", "CENTER")
  ) +
  tm_compass(type = "4star", size = 2, position = c("RIGHT", "TOP")) +
  tm_scalebar(text.size = 0.5, position = c("LEFT", "BOTTOM"))

# Mostrar o mapa
suit_fut
tmap_save(suit_fut, paste0("outputs/suit_future/suit_with_mop_", scenario, "_", subgenus, ".jpg"), dpi = 600, height = 10, width = 10)
