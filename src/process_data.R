# https://liibre.github.io/Rocc/articles/articles/using_rspeciesLink.html
library(tidyverse)
library(rgbif)
library(leaflet)
library(Rocc)


df <-
  read.table("data/all_anopheles.txt", header = T) %>%
  rename(species = Especie, 
         decimalLatitude = Latitude, 
         decimalLongitude = longitude) %>%
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


# ver package species link
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


# bind dfs api ------------------------------------------------------------

anopheles_df <-
  all_species_gbif %>%
  bind_rows(all_species_splink, df)


anopheles_df <-
  anopheles_df[
    !duplicated(paste(
      anopheles_df$species,
      anopheles_df$decimalLongitude,
      anopheles_df$decimalLatitude
    )),
  ]

# tratamento da escrita das espécies

levels(as.factor(anopheles_df$species))

teste <- anopheles_df %>% 
  mutate(species = case_when(
    species == 'Anopheles albitarsis?' ~ 'Anopheles albitarsis',
    species == 'Anopheles oswaldoi?' ~ 'Anopheles oswaldoi' ,
    species == 'Anopheles triannulatus s.l.' ~ 'Anopheles triannulatus',
    species == 'Anopheles albimanus section' ~ 'Anopheles albimanus',
    species == 'Anopheles albitarsis s.l.' ~ 'Anopheles albitarsis',
    species == 'Anopheles aquasalis?' ~ 'Anopheles aquasalis',
    species == 'Anopheles argyritarsis section' ~ 'Anopheles argyritarsis',
    species == 'Anopheles fluminensis *' ~ 'Anopheles fluminensis',
    species == 'Anopheles mediopunctatus *' ~ 'Anopheles mediopunctatus',
    species == 'Anopheles rangeli?' ~ 'Anopheles rangeli',
    TRUE ~ species
    ))

levels(as.factor(teste$species))
