source("src/utils/functions.R")
source("src/utils/libraries.R")

list_file_current <-
  list.files(
    path = paste0(getwd(), "/data/bioclim_layer/CMIP6/Current"),
    pattern = "\\.asc$", full.names = T
  )

current_neotropic_layer <-
  stack(list_file_current)

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

plot(neotropic)
for (specie in seq_along(species_list)) {
  for (km in seq_along(buffer_area_list)) {
    # Buffer Area -------------------------------------------------------------
    sp_name <- species_list[[specie]]
    path_workflow <- paste0("data/workflow_maxent/", sp_name)
    km <- buffer_area_list[[km]]
    path_cal <- paste0(path_workflow, "/km_", km)
    dir_create(path_cal)

    occ <- read.csv(paste0(
      path_workflow, "/", sp_name, "_joint.csv"
    ))


    WGS84 <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
    occ_sp <- SpatialPointsDataFrame(
      coords = occ[, 2:3], data = occ,
      proj4string = WGS84
    )

    ## project the points using their centroids as reference
    centroid <- gCentroid(occ_sp, byid = FALSE)
    AEQD <- CRS(paste("+proj=aeqd +lat_0=", centroid@coords[2], " +lon_0=", centroid@coords[1],
      " +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs",
      sep = ""
    ))

    occ_pr <- spTransform(occ_sp, AEQD)

    ## create a buffer based on a x km distance
    buffer_area <- gBuffer(occ_pr, width = km * 1000, quadsegs = 30)
    buffer_area_terra <- terra::vect(buffer_area)
    buffer_area_disagg <- disagg(buffer_area_terra)

    ## reproject
    buffer_area <- spTransform(buffer_area, WGS84)

    ## make spatialpolygondataframe
    df <- data.frame(species = rep(sp_name, length(buffer_area)))
    buffer_area <- SpatialPolygonsDataFrame(buffer_area, data = df, match.ID = FALSE)

    ## write area as shapefile
    dir_create(paste0(path_cal, "/Calibration_area_", km))
    dir_create(paste0(path_cal, "/Calibration_area_", km, "/shapefile"))
    writeOGR(buffer_area,
      paste0(path_cal, "/Calibration_area_", km, "/shapefile"),
      "M",
      driver = "ESRI Shapefile", overwrite_layer = T
    )

    tm_shape(neotropic) +
      tm_polygons(border.alpha = 0.3) +
      tm_shape(occ_sp) +
      tm_dots(size = 0.05) +
      tm_shape(buffer_area) +
      tm_borders()

    M <- buffer_area

    # masking layers to M
    mask_layers <- mask(crop(current_neotropic_layer, M), M)

    # saving masked layers as ascii files
    lapply(names(mask_layers), function(x) {
      writeRaster(mask_layers[[x]],
        paste0(
          path_cal,
          "/Calibration_area_", km, "/", x, ".asc"
        ),
        overwrite = T
      )
    })
  }
}
