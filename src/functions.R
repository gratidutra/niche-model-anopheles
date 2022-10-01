# função pra criar diretório

dir_create <- function(dir_name) {
  if (!file.exists(dir_name)) {
    dir.create(dir_name)
    print("diretório criado")
  } else {
    print("diretório já existe")
  }
}

# função pra cortar camadas

crop_raster <- function(raster_list, shp, path) {
  new_raster_list <- list()
  i <- 1
  while (i <= length(raster_list)) {
    new_raster_list[[i]] <-
      raster::crop(raster_list[[i]], shp)
    writeRaster(new_raster_list[[i]],
      paste0(path, "/bio", i, ".asc"),
      overwrite = T
    )
    i <- i + 1
  }
  return(new_raster_list)
}

# função para splitar dataframes por espécies

data_by_species <- function(data, list_species, path) {
  list_data <- list()
  for (i in seq_along(list_species)) {
    list_data[[i]] <- data %>%
      dplyr::filter(species == list_species[[i]])
    write.csv(list_data[[i]],
      paste0(path, "/", list_data[[i]]$species[1], ".csv"),
      row.names = F
    )
  }
  return(list_data)
}
