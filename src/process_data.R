# https://liibre.github.io/Rocc/articles/articles/using_rspeciesLink.html
library(tidyverse)
library(rgbif)
library(leaflet)
library(Rocc)


df <-
  read.table("data/all_anopheles.txt", header = T)

splist <-
  levels(as.factor(df$Especie))

splist <-
  gsub("_", " ", splist)

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
  user = "gratidutra", pwd = "iNm!cD!U6@3LhYH", email = "gratirodrigues.gdr@gmail.com"
)

z <- occ_download_get(occ_anopheles)

all_species <- occ_download_import(z)

all_species_gbif <-
  all_species %>%
  select(species, decimalLatitude, decimalLongitude) %>%
  drop_na()


# ver package species link
# trocar para variavel de ambiente as credenciais

all_species_gbif <-
  all_species_gbif[
    !duplicated(paste(
      all_species_gbif$species, all_species_gbif$decimalLongitude,
      all_species_gbif$decimalLatitude
    )),
  ]


# leaflet(all_species_gbif) %>%
#   addTiles() %>%
#   addMarkers(
#     lng = ~decimalLongitude, lat = ~decimalLatitude,
#     popup = paste(all_species_gbif$decimalLongitude, all_species_gbif$decimalLatitude)
#   )


# Species Link ------------------------------------------------------------

all_species_splink_raw <- 
  rspeciesLink(filename = "all_species_splink",
                     species = splist,
                     Coordinates = "Yes",
                     CoordinatesQuality = "Good")

all_species_splink <-
  all_species_splink_raw[
    !duplicated(paste(
      all_species_splink_raw$scientificName,
      all_species_splink_raw$decimalLongitude,
      all_species_splink_raw$decimalLatitude
    )),
  ]

all_species_splink <- all_species_splink %>%
  rename(species = scientificName) %>%
  select(species, decimalLatitude, decimalLongitude) %>%
  mutate(decimalLatitude = as.numeric(decimalLatitude),
         decimalLongitude = as.numeric(decimalLongitude))

all_species_gbif %>% bind_rows(all_species_splink)
