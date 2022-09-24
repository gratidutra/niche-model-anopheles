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

crop_raster <- function(raster_list, shp) {
  new_raster_list <- list()
  i <- 1
  while (i <= length(raster_list)) {
    new_raster_list[[i]] <-
      raster::crop(raster_list[[i]], shp)
    i <- i + 1
  }
  return(raster_neotropic_list)
}

# função para splitar dataframes por espécies

data_by_species <- function(data, list_species) {
  list_data <- list()
  for (i in seq_along(splist)) {
    list_data[[i]] <- data %>%
      dplyr::filter(species == list_species[[i]])
  }
  return(list_data)
}
