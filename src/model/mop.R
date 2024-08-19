library(kuenm)
library(tidyverse)
source("src/utils/functions.R")

species_list <- c(
  "Anopheles_albitarsis", "Anopheles_apicimacula",
  "Anopheles_aquasalis", "Anopheles_argyritarsis", "Anopheles_braziliensis",
  "Anopheles_darlingi", "Anopheles_eiseni", "Anopheles_evansae",
  "Anopheles_intermedius", "Anopheles_mediopunctatus",
  "Anopheles_oswaldoi", "Anopheles_peryassui", "Anopheles_pseudopunctipennis",
  "Anopheles_punctimacula", "Anopheles_rangeli", "Anopheles_strodei",
  "Anopheles_triannulatus", "Anopheles_rangeli"
)

buffer_area_list <- c(100, 200, 250, 300, 400, 500)

maxent_path <- getwd()

for (specie in seq_along(species_list)) {
  for (km in seq_along(buffer_area_list)) {
    sp_name <- species_list[[specie]]
    km <- buffer_area_list[[km]]

    print(paste("/-/-/-/-/-/-/-/-/-/-/-/-", sp_name, km, "/-/-/-/-/-/-/-/-/-/-/-/-"))

    path_specie <- paste0("data/workflow_maxent/", sp_name)
    path_buffer <- paste0("data/workflow_maxent/", sp_name, "/km_", km)
    # Params ------------------------------------------------------------------
    if (file.exists(paste0(path_specie, "km_250/Final_Models_evaluation/fm_evaluation_results.csv"))) {
      G_var_dir <-
        paste0(path_buffer, "/G_variables")

      M_var_dir <-
        paste0(path_buffer, "/Model_calibration/M_variables")

      # fm_eval_df <- read.csv(paste0(path_buffer,'/Final_Models_evaluation/fm_evaluation_results.csv'))

      sets_var <- "Set_1"

      out_mop <- paste0(path_buffer, "/MOP_kuenm")
      percent <- 10
      paral <- FALSE

      mop_dir <- paste0(path_buffer, "/MOP_kuenm")
      format <- "GTiff"
      curr <- "current"
      time_periods <- 60
      emi_scenarios <- c("126", "585")
      out_dir <- paste0(path_buffer, "/MOP_agremment_kuenm")

      kuenm_mmop(
        G.var.dir = G_var_dir, M.var.dir = M_var_dir,
        is.swd = FALSE, sets.var = sets_var,
        out.mop = out_mop, percent = percent
      )

      kuenm::kuenm_mopagree(
        mop.dir = mop_dir, in.format = format, out.format = format,
        current = curr, time.periods = time_periods,
        emi.scenarios = emi_scenarios, out.dir = out_dir
      )
    } else {
      print(paste("File in", sp_name, "-", km, "don't exist"))
    }
  }
}
