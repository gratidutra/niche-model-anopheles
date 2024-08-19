library(raster)
library(terra)
library(tmap)
library(tidyverse)
library(dichromat)
library(sf)

sp <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_aquasalis",
  "Anopheles_argyritarsis", "Anopheles_braziliensis", "Anopheles_darlingi",
  "Anopheles_evansae", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)

shapefile <- st_read("data/raw/raster/Neotropic/Neotropic.shp")

tresh_presence <- read.csv('data/pre_results/treshold_presence.csv') 

layer_list <- list()

scenarios <- c("126", "585")

area_data_fut <- data.frame()

for (specie in seq_along(sp)) {
  sp_name <- sp[[specie]]
  
  tresh_presence_specie <- tresh_presence %>% 
    dplyr::filter(`method` != '10_percentile' , `species` == sp_name) %>% 
    dplyr::select(`value`)

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

  for (scenario in seq_along(scenarios)) {
    if (sp_name %in% c("Anopheles_albimanus", "Anopheles_nuneztovari")) {
      mop <- raster(
        paste0(
          path_cal,
          "/MOP_agremment_kuenm/Set_2/MOP_10%_60_", scenarios[[scenario]], "_agreement.tif"
        )
      )
      ogcm_1 <- raster(
        paste0(
          path_cal,
          "Final_models/", model[[1]], "_EC/", sp_name, "_",
          "future_layer_can_", scenarios[[scenario]], "_60_median.asc"
        )
      )

      ogcm_2 <- raster(
        paste0(
          path_cal,
          "Final_models/", model[[1]], "_EC/", sp_name, "_",
          "future_layer_mc_", scenarios[[scenario]], "_60_median.asc"
        )
      )
    } else {
      mop <- raster(
        paste0(
          path_cal,
          "/MOP_agremment_kuenm/Set_1/MOP_10%_60_", scenarios[[scenario]], "_agreement.tif"
        )
      )

      ogcm_1 <- raster(
        paste0(
          path_cal,
          "Final_models/", model[[1]], "_EC/", sp_name, "_",
          "future_layer_can_", scenarios[[scenario]], "_60_median.asc"
        )
      )

      ogcm_2 <- raster(
        paste0(
          path_cal,
          "Final_models/", model[[1]], "_EC/", sp_name, "_",
          "future_layer_mc_", scenarios[[scenario]], "_60_median.asc"
        )
      )
    }

    agree_ogcm <- raster::mosaic(ogcm_1, ogcm_2, fun = mean)

    crs(mop) <- crs(agree_ogcm)

    ogcm_cropped <-
      crop(agree_ogcm, extent(mop))

    mop[mop != 0] <- NA

    suit_non_risk <-
      mask(ogcm_cropped, mop)

    suit_non_risk[suit_non_risk < tresh_presence_specie[[1]]] <- NA
    names(suit_non_risk) <- sp_name

    s <- summary(suit_non_risk)
    if (is.na(s[[1]]) & is.na(s[[5]])) {
      new_line <- data.frame(
        sp_name = sp_name,
        scenario = scenarios[[scenario]],
        area = 0
      )
      area_data_fut <- bind_rows(area_data_fut, new_line)
    } else {
      cell_size <- area(suit_non_risk, na.rm = TRUE, weights = FALSE)
      cell_size <- cell_size[!is.na(cell_size)]
      # compute area [km2] of all cells in geo_raster
      area <- length(cell_size) * median(cell_size)
      new_line <- data.frame(
        sp_name = sp_name,
        scenario = scenarios[[scenario]],
        area = area
      )
      area_data_fut <- bind_rows(area_data_fut, new_line)
    }
    print(sp_name)
  }
}

area_data_fut
