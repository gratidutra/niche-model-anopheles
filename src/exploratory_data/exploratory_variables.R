source("src/utils/functions.R")
source("src/utils/libraries.R")

# download camadas present e recorte
path_cmip6 <- paste0("data/bioclim_layer")
dir_create(path_cmip6)
path_cmip6 <- paste0("data/bioclim_layer/CMIP6")
dir_create(path_cmip6)

neotropic <-
  readOGR(
    dsn = ("data/raw/raster/Neo"),
    layer = "Neo",
    verbose = FALSE
  )

path_cmip6 <- paste0("data/bioclim_layer/CMIP6")
dir_create(path_cmip6)


tavg_layer <-
  geodata::worldclim_global(
    "tavg",
    res = 10,
    path = getwd()
  )

tavg <-
  crop_raster_cmip6(
    tavg_layer, neotropic,
    paste0(path_cmip6, "/climate"), 
    n=1:12, name='tavg'
  )

plot(tavg)
