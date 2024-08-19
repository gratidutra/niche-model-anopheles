library(tmap)
library(raster)
library(tidyverse)
library(dichromat)
library(readxl)
library(rinat)
library(sf)
library(ggforce)
library(patchwork)

ny <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_aquasalis",
  "Anopheles_argyritarsis", "Anopheles_braziliensis", "Anopheles_darlingi",
  "Anopheles_evansae", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)

data_list <- list()

neotropico_lims <- list(
  xlim = c(-130, -35), 
  ylim = c(-60, 30)     
)

for (sp_name in seq_along(ny)) {
  data <- read.csv(
    paste0("data/workflow_maxent/", ny[[sp_name]], "/", ny[[sp_name]], "_joint.csv")
    ) 
  data_list[[sp_name]] <- data
}

combined_df <- do.call(rbind, data_list)

especies_unicas <- unique(combined_df$species)
letras <- LETTERS[1:length(especies_unicas)]
nomes_com_letras <- setNames(letras, especies_unicas)

combined_df$species_com_letras <- 
  paste(nomes_com_letras[combined_df$species], 
        combined_df$species, sep = "- ")


neotropico_lims <- list(
  xlim = c(-130, -35),  
  ylim = c(-60, 30)   
)

p <- ggplot(data = combined_df, aes(x = longitude, y = latitude, colour = species_com_letras)) +
  geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group),
               fill = "grey95", color = "gray40", size = 0.1) +
  geom_point(size = 0.7, alpha = 0.5) +
  geom_mark_hull(aes(fill = species_com_letras), expand = unit(1, "mm"), radius = unit(1, "mm"), label.fill = "transparent") +
  scale_x_continuous(expand = expansion(add = 0.1), limits = neotropico_lims$xlim) +
  scale_y_continuous(expand = expansion(add = 0.1), limits = neotropico_lims$ylim) +
  coord_fixed(xlim = neotropico_lims$xlim, ylim = neotropico_lims$ylim) +
  facet_wrap(~species_com_letras) +
  theme_no_axes() +
  theme(
    legend.position = "none",
    axis.title.x = element_blank(),  # Remover o título do eixo x
    axis.title.y = element_blank(),  # Remover o título do eixo y
    axis.text.x = element_blank(),    # Remover texto do eixo x
    axis.text.y = element_blank(),
    strip.text = element_text(face = "italic")# Remover texto do eixo y
  )

ggsave('outputs/plot_points.jpg', dpi = 600, height = 10, width = 10)
