library(tidyverse)

ny <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_aquasalis",
  "Anopheles_argyritarsis", "Anopheles_braziliensis", "Anopheles_darlingi",
  "Anopheles_evansae", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)
area_long <- 
  read.csv('data/pre_results/area_long.csv') %>%
  select(-X) %>% 
  rename(`Cenário` = scenario)

ny = gsub("_", " ", ny)

change <- 
  ggplot(data = area_long, 
         aes(x = sp_name, y = area, fill = `Cenário`)) +
  geom_bar(stat = "identity", color = "black", position = position_dodge()) +
  geom_text(aes(label = round(area)),
            vjust = 1.6, color = "black",
            position = position_dodge(0.9), size = 3.5
  ) +
  scale_fill_brewer(palette = "Accent") +
  xlab("Espécies")+
  ylab("Area de mudança (%)")+
  theme_minimal()+
  # scale_x_discrete(guide = guide_axis(angle = 90), )+
  theme(
    axis.text.x = element_text(
      color = "black", face = 'italic',
      size = 14, angle = 60, vjust = 0.6
    ),
    axis.title.x = element_text(size = 14),
    axis.text.y = element_text(color = "black",size = 14
    ),
    axis.title.y = element_text(size = 14)
  )+
  annotate("text", x = 4, y = 30, label = "*", color = "red", size = 7) +
  annotate("text", x = 10, y = 30, label = "*", color = "red", size = 7)

change

ggsave("outputs/change_ny.png", plot = change, width = 16, height = 8, dpi = 300)
