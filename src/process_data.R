library(tidyverse)
library(rgbif)
library(leaflet)
library(Rocc)
library(rgdal)
library(rgeos)
library(raster)
library(sp)
library(maptools)
library(tmap)
library(sf)

source("functions.R")

df <-
  read.table("data/raw/all_anopheles.txt", header = T) %>%
  rename(
    species = Especie,
    decimalLatitude = Latitude,
    decimalLongitude = longitude
  ) %>%
  mutate(species = gsub("_", " ", species))

splist <-
  levels(as.factor(df$species))

keys <-
  lapply(
    splist,
    function(x) name_suggest(x)$data$key[1]
  )

# problema no limite de requisições

occ_anopheles <- occ_download(
  pred_in("taxonKey", keys),
  pred("hasCoordinate", TRUE),
  format = "SIMPLE_CSV",
  user = "gratidutra", pwd = "iNm!cD!U6@3LhYH",
  email = "gratirodrigues.gdr@gmail.com"
)

z <- occ_download_get(occ_anopheles)

all_species <- occ_download_import(z)

all_species_gbif <-
  all_species %>%
  select(species, decimalLatitude, decimalLongitude) %>%
  drop_na()


# trocar para variavel de ambiente as credenciais

# Species Link ------------------------------------------------------------

all_species_splink_raw <-
  rspeciesLink(
    filename = "all_species_splink",
    species = splist,
    Coordinates = "Yes",
    CoordinatesQuality = "Good"
  )

all_species_splink <- all_species_splink_raw %>%
  rename(species = scientificName) %>%
  select(species, decimalLatitude, decimalLongitude) %>%
  mutate(
    decimalLatitude = as.numeric(decimalLatitude),
    decimalLongitude = as.numeric(decimalLongitude)
  )


# Unindo e tratando o df final--------------------------------------------------

anopheles_df <-
  all_species_gbif %>%
  bind_rows(all_species_splink, df)

# tratamento da escrita das espécies

levels(as.factor(anopheles_df$species))

anopheles_df <- anopheles_df %>%
  mutate(species = case_when(
    species == "Anopheles albitarsis?" ~ "Anopheles albitarsis",
    species == "Anopheles oswaldoi?" ~ "Anopheles oswaldoi",
    species == "Anopheles triannulatus s.l." ~ "Anopheles triannulatus",
    species == "Anopheles albimanus section" ~ "Anopheles albimanus",
    species == "Anopheles albitarsis s.l." ~ "Anopheles albitarsis",
    species == "Anopheles aquasalis?" ~ "Anopheles aquasalis",
    species == "Anopheles argyritarsis section" ~ "Anopheles argyritarsis",
    species == "Anopheles fluminensis *" ~ "Anopheles fluminensis",
    species == "Anopheles mediopunctatus *" ~ "Anopheles mediopunctatus",
    species == "Anopheles rangeli?" ~ "Anopheles rangeli",
    TRUE ~ species
  ))

levels(as.factor(anopheles_df$species))

# removendo as duplicatas

anopheles_processed1 <-
  anopheles_df[
    !duplicated(paste(
      anopheles_df$species,
      anopheles_df$decimalLongitude,
      anopheles_df$decimalLatitude
    )),
  ]

dir_create("data/processed")

# arrumando pontos que deram ruim no processamento

anopheles_processed2 <-
  anopheles_processed %>%
  mutate(decimalLongitude = case_when(
    decimalLongitude == -546264.0000 ~ -54.6264,
    TRUE ~ decimalLongitude
  ))


# shapefile

neotropic <-
  readOGR(
    dsn = ("data/raw/raster"),
    layer = "Neotropic",
    verbose = FALSE
  )

# identificando pontos fora do shape

anopheles_processed2["inout"] <- over(
  SpatialPoints(anopheles_processed[
    , c("decimalLongitude", "decimalLatitude")
  ], proj4string = CRS(projection(neotropic))),
  as(neotropic, "SpatialPolygons")
)

# dropando pontos fora do shape

anopheles_processed3 <- anopheles_processed2 %>%
  drop_na(.)

# salvando csv

write.csv(anopheles_processed3, "data/processed/anopheles_processed.csv")

# df para o kmeans 

kmeans <- anopheles_processed3 %>%
  group_by(decimalLatitude, decimalLongitude) %>%
  summarise(rich = n_distinct(species))

write.csv(kmeans, "data/processed/kmeans.csv")


# criando objeto pro plot via tmap e plotando

anopheles_points_plot <- anopheles_processed3 %>%
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326) %>%
  st_cast("POINT")

tm_shape(neotropic) +
  tm_polygons(border.alpha = 0.3) +
  tm_shape(anopheles_points_plot) +
  tm_dots(size = 0.05)
