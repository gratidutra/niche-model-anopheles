source("src/utils/functions.R")
source("src/utils/libraries.R")

species_list <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_apicimacula",
  "Anopheles_aquasalis", "Anopheles_argyritarsis", "Anopheles_braziliensis",
  "Anopheles_darlingi", "Anopheles_eiseni", "Anopheles_evansae", "Anopheles_intermedius",
  "Anopheles_mediopunctatus", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_peryassui", "Anopheles_pseudopunctipennis", "Anopheles_punctimacula",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)

buffer_area_list <- c(100, 200, 250, 300, 400, 500)

neotropic <-
  readOGR(
    dsn = ("data/raw/raster/Neo"),
    layer = "Neo",
    verbose = FALSE
  )

for (specie in seq_along(species_list)) {
  for (km in seq_along(buffer_area_list)) {
    # Buffer Area -------------------------------------------------------------
    sp_name <- species_list[[specie]]
    path_workflow <- paste0("data/workflow_maxent/", sp_name)
    km <- buffer_area_list[[km]]
    dir_create(paste0(path_workflow, "/outputs"))
    path_cal <- paste0(path_workflow, "/km_", km)
    occ <- read.csv(
      paste0(
        path_workflow, "/", sp_name, "_train.csv"
      )
    )

    list_file_current <-
      list.files(
        path = paste0(path_cal, "/Calibration_area_", km),
        pattern = "\\.asc$", full.names = T
      )

    varsm <-
      stack(list_file_current)


    # Pearson Correlation  ----------------------------------------------------

    temp <- stack(
      varsm$bio1, varsm$bio2, varsm$bio3, varsm$bio4,
      varsm$bio5, varsm$bio6, varsm$bio7,  varsm$bio8,  varsm$bio9,
      varsm$bio10, varsm$bio11, varsm$bio20 
    )

    prec <- stack(
      varsm$bio12, varsm$bio13, varsm$bio14, varsm$bio15,
      varsm$bio16, varsm$bio17, varsm$bio18,  varsm$bio19, 
      varsm$bio20
    )

    ## only temperature variables

    explore_espace(
      data = occ, species = "species", longitude = "longitude",
      latitude = "latitude", raster_layers = temp, save = T,
      # arrumar o destino aqui
      name = paste0(path_workflow, "/outputs/Temperature_variables_", km, ".pdf")
    )

    ## only precipitation variables

    explore_espace(
      data = occ, species = "species", longitude = "longitude",
      latitude = "latitude", raster_layers = prec, save = T,
      # arrumar o destino aqui
      name = paste0(path_workflow, "/outputs/Precipitation_variables_", km, ".pdf")
    )
  }
}
