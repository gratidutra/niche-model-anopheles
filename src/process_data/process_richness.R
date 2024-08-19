source("src/utils/functions.R")
source("src/utils/libraries.R")

dir_create('data/richness')
path <- 'data/richness' 

list_file_current <-
  list.files(
    path = paste0("data/processed/data_by_specie"),
    pattern = "\\.csv$", full.names = T
  )

data_thinned <- read_csv(list_file_current)

# Raw area ----------------------------------------------------------------

neotropic <-
  readOGR(
    dsn = ("data/raw/raster"),
    layer = "Neotropic",
    verbose = FALSE
  )

# Bioclims ----------------------------------------------------------------

list_file_current <-
  list.files(
    path = paste0("data/bioclim_layer/CMIP6/Current"),
    pattern = "\\.asc$", full.names = T
  )

varsm <-
  stack(list_file_current)


# Pearson Correlation  ----------------------------------------------------

dir_create('data/richness/outputs')

temp <- stack(
  varsm$bio1, varsm$bio2, varsm$bio3, varsm$bio4,
  varsm$bio5, varsm$bio6, varsm$bio7, varsm$bio8,
  varsm$bio9, varsm$bio10, varsm$bio11
)

prec <- stack(
  varsm$bio12, varsm$bio13, varsm$bio14, varsm$bio15,
  varsm$bio16, varsm$bio17, varsm$bio18, varsm$bio19
)

## only temperature variables

explore_espace(
  data = occ, species = "species", longitude = "longitude",
  latitude = "latitude", raster_layers = temp, save = T,
  name = "data/richness/outputs/tempereture_richness.pdf"
)

## only precipitation variables

explore_espace(
  data = occ, species = "species", longitude = "longitude",
  latitude = "latitude", raster_layers = prec, save = T,
  name = "data/richness/outputs/precipitation_richness.pdf"
)

# M_var -------------------------------------------------------------------

dir_create('data/richness/M_var')

# Concave Area ------------------------------------------------------------

cv_area <- 
  concave_area(data = data_thinned, longitude = "longitude",
               latitude = "latitude",buffer_distance = 400, 
               raster_layers = varsm, mask = T, save = T, 
               name = 'data/richness/M_var/calib_area_concave')

raster::plot(cv_area$masked_variables[[1]])
sp::plot(cv_area$calibration_area, add = TRUE)
points(data_thinned[, 2:3])

cv_vars <- cv_area$masked_variables

temp <- stack(
  cv_vars$bio1, cv_vars$bio2, cv_vars$bio3, cv_vars$bio4,
  cv_vars$bio5, cv_vars$bio6, cv_vars$bio7, cv_vars$bio8,
  cv_vars$bio9, cv_vars$bio10, cv_vars$bio11
)

prec <- stack(
  cv_vars$bio12, cv_vars$bio13, cv_vars$bio14, cv_vars$bio15,
  cv_vars$bio16, cv_vars$bio17, cv_vars$bio18, cv_vars$bio19
)

explore_espace(
  data = data_thinned, species = "species", longitude = "longitude",
  latitude = "latitude", raster_layers = temp, 
  save = T,
  name = "data/richness/outputs/tempereture_richness_cv.pdf"
)

## only precipitation variables

explore_espace(
  data = data_thinned, species = "species", longitude = "longitude",
  latitude = "latitude", raster_layers = prec, save = T,
  name = "data/richness/outputs/precipitation_richness_cv.pdf"
)

# Convex Area ------------------------------------------------------------
cx_area <- convex_area(data = data_thinned, longitude = "longitude",
                        latitude = "latitude",buffer_distance = 400, 
                        raster_layers = varsm, mask = T, save = T, 
                        name = 'data/richness/M_var/calib_area_convex')

raster::plot(cx_area$masked_variables[[1]])
sp::plot(cx_area$calibration_area, add = TRUE)
points(data_thinned[, 2:3])

cx_vars <- cx_area$masked_variables

temp <- stack(
  cx_vars$bio1, cx_vars$bio2, cx_vars$bio3, cx_vars$bio4,
  cx_vars$bio5, cx_vars$bio6, cx_vars$bio7, cx_vars$bio8,
  cx_vars$bio9, cx_vars$bio10, cx_vars$bio11
)

prec <- stack(
  cx_vars$bio12, cx_vars$bio13, cx_vars$bio14, cx_vars$bio15,
  cx_vars$bio16, cx_vars$bio17, cx_vars$bio18, cx_vars$bio19
)

explore_espace(
  data = data_thinned, species = "species", longitude = "longitude",
  latitude = "latitude", raster_layers = temp, save = T,
  name = "data/richness/outputs/tempereture_richness_cx.pdf"
)

## only precipitation variables

explore_espace(
  data = data_thinned, species = "species", longitude = "longitude",
  latitude = "latitude", raster_layers = prec, save = T,
  name = "data/richness/outputs/precipitation_richness_cx.pdf"
)