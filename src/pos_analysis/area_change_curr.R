library(raster)
library(terra)
library(tmap)
library(tidyverse)
library(dichromat)
library(sf)
source('src/pos_analysis/area_suit_fut_km.R')

sp <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_aquasalis",
  "Anopheles_argyritarsis", "Anopheles_braziliensis", "Anopheles_darlingi",
  "Anopheles_evansae", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)

shapefile <- st_read("data/raw/raster/Neotropic/Neotropic.shp")

tresh_presence <- read.csv('data/pre_results/treshold_presence.csv')

layer_list <- list()

area_data_curr <- data.frame()

for (specie in seq_along(sp)) {
  sp_name <- sp[[specie]]
  
  tresh_presence_specie <- tresh_presence %>% 
    dplyr::filter(method == 'maxSSS' & species == sp_name) %>% 
    dplyr::select(value)
  
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
          "/MOP_results/Set_2/MOP_10%_Current.tif"
        )
      )
      ogcm <- raster(
        paste0(
          path_cal,
          "Final_models/", model[[1]], "_EC/", sp_name, 
          "_Current_median.asc"
        )
      )
      
    } else {
      mop <- raster(
        paste0(
          path_cal,
          "/MOP_results/Set_1/MOP_10%_Current.tif"
        )
      )
      
      ogcm <- raster(
        paste0(
          path_cal,
          "Final_models/", model[[1]], "_EC/", sp_name,
          "_Current_median.asc"
        )
      )
    
    }
    
    crs(mop) <- crs(ogcm)
    
    ogcm_cropped <-
      crop(ogcm, extent(mop))
    
    mop[mop == 0] <- NA
    
    suit_non_risk <-
      mask(ogcm_cropped, mop)
    
    suit_non_risk[suit_non_risk < tresh_presence_specie[[1]]] <- NA
    names(suit_non_risk) <- sp_name
    
    s <- summary(suit_non_risk)
    if (is.na(s[[1]]) & is.na(s[[5]])) {
      new_line <- data.frame(
        sp_name = sp_name,
        scenario = 'Current',
        area = 0
      )
      area_data_curr <- bind_rows(area_data_curr, new_line)
    } else {
      cell_size <- area(suit_non_risk, na.rm = TRUE, weights = FALSE)
      cell_size <- cell_size[!is.na(cell_size)]
      # compute area [km2] of all cells in geo_raster
      area <- length(cell_size) * median(cell_size)
      new_line <- data.frame(
        sp_name = sp_name,
        scenario = 'Current',
        area = area
      )
      area_data_curr <- bind_rows(area_data_curr, new_line)
    }
    
    print(sp_name)
}

suit_comparison_data <- 
  area_data_curr %>% 
  bind_rows(area_data_fut)

area_wider <-
  suit_comparison_data %>%
  pivot_wider(names_from = c(scenario), values_from = area)

area_wider <- 
  area_wider  %>% 
  mutate(change_126 = (`126`*100/Current)-100,
         change_585 = (`585`*100/Current)-100)

area_long <- 
  area_wider %>% 
  select(sp_name,change_126, change_585) %>% 
  pivot_longer( cols = starts_with("change"),
                names_to = "scenario",
                names_prefix = "change",
                values_to = "area",
                values_drop_na = TRUE) %>% 
  mutate(sp_name = gsub("_", " ", sp_name))

write.csv(area_long, 'data/pre_results/area_long.csv')
