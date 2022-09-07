library(tidyverse)
library(rgbif)

df <-
  read.table("data/all_anopheles.txt", header = T)

splist <-
  levels(as.factor(df$Especie))

splist <-
  gsub("_", " ", splist)

keys <-
  lapply(
    splist[1:5],
    function(x) name_suggest(x)$data$key[1]
  )

# problema no limite de requisições

sp_an <-
  occ_search(taxonKey = keys, limit = 500)

datalist <-
  vector("list", length = 5)

for (i in 1:5) {
  datalist[[i]] <- sp_an[[i]]$data %>%
    dplyr::select(species, decimalLatitude, decimalLongitude)
}

all_species <-
  do.call(rbind, datalist) %>%
  drop_na(.)
