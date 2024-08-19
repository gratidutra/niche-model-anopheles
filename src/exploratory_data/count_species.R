source("src/utils/libraries.R")
source("src/functions.R")
library(data.table)
load_dot_env(file = ".env")

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
  user = Sys.getenv("USER_GBIF"), pwd = Sys.getenv("PWD_GBIF"),
  email = Sys.getenv("EMAIL")
)

all_species <-
  occ_download_get(key = "0155603-230224095556074", overwrite = TRUE) %>%
  occ_download_import()

all_species_gbif <-
  all_species %>%
  dplyr::select(species, decimalLatitude, decimalLongitude) %>%
  drop_na()

# Species Link ------------------------------------------------------------

all_species_splink_raw <- 
  read.csv('data/raw/gbif_splink/all_species_splink.csv')

all_species_splink <-
  all_species_splink_raw %>%
  rename(species = scientificName) %>%
  dplyr::select(species, decimalLatitude, decimalLongitude) %>%
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

ny <- c(
  "Anopheles albimanus", "Anopheles albitarsis", "Anopheles aquasalis",
  "Anopheles braziliensis", "Anopheles evansae", "Anopheles nuneztovari",
  "Anopheles oswaldoi", "Anopheles strodei", "Anopheles triannulatus"
)

ke <- c(
  "Anopheles apicimacula", "Anopheles eiseni", "Anopheles intermedius",
  "Anopheles mediopunctatus", "Anopheles peryassui", "Anopheles pseudopunctipennis",
  "Anopheles punctimacula")


anopheles_df %>% 
  dplyr::filter(species %in% ny) %>% 
  nrow()

anopheles_df %>% 
  dplyr::filter(species %in% ke) %>% 
  nrow()
