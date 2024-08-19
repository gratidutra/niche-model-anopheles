library(tmap)
library(raster)
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
  "Anopheles_mediopunctatus", "Anopheles_peryassui", 
  "Anopheles_pseudopunctipennis", "Anopheles_punctimacula"
)

layer_list <- c()

list_sp <- an

subgenus <- "an"

scenario <- "126"

for (specie in seq_along(list_sp)) {
  sp_name <- list_sp[[specie]]

  selected_model <-
    read.csv(paste0(getwd(), "/data/selected_models_1.csv")) %>%
    dplyr::filter(species == sp_name) %>%
    dplyr::select(best_model)

  selected_model[[1]] <- gsub(" ", "_", as.factor(selected_model[[1]]))
  path_cal <- paste0(
    getwd(),
    "/data/workflow_maxent/",
    sp_name, "/",
    selected_model[[1]]
  )

  if (sp_name %in% c("Anopheles_albimanus", "Anopheles_nuneztovari")) {
    layer <- raster(
      paste0(
        path_cal,
        "/MOP_agremment_kuenm/Set_2/MOP_10%_60_", scenario, "_agreement.tif"
      )
    )
  } else {
    layer <- raster(
      paste0(
        path_cal,
        "/MOP_agremment_kuenm/Set_1/MOP_10%_60_", scenario, "_agreement.tif"
      )
    )
  }

  layer_list <- c(layer_list, layer)
  print(layer_list)
}

# Defina as cores para cada categoria
layer_list <- stack(layer_list)

# Defina as cores para cada categoria
cores <- c("white", "#e43838", "#183535")

# Crie um tema para o tmap
my_theme <- tm_layout(frame = FALSE)

list_sp <- gsub("_", " ", list_sp)

# Plote o raster categórico com a paleta de cores definida
mop <- tm_shape(layer_list) +
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

tmap_save(mop, 
          paste0(getwd(),"/outputs/mop_teste_", subgenus, "_", scenario, ".svg"),
          height=10, width=10)
mop
