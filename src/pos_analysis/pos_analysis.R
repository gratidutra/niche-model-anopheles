library(kuenm)
library(tidyverse)

species_list <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_apicimacula",
  "Anopheles_aquasalis", "Anopheles_argyritarsis", "Anopheles_braziliensis",
  "Anopheles_darlingi", "Anopheles_eiseni", "Anopheles_evansae", "Anopheles_intermedius",
  "Anopheles_mediopunctatus", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_peryassui", "Anopheles_pseudopunctipennis", "Anopheles_punctimacula",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)

buffer_area_list <- c(100,200,250,300,400)

maxent_path <- getwd()

for (specie in seq_along(species_list)) {
  for (km in seq_along(buffer_area_list)) {
    sp_name <- species_list[[specie]]
    km_ <- buffer_area_list[[km]]

    path_specie <- paste0("data/workflow_maxent/", sp_name)
    path_cal <- paste0(path_specie, "/km_", km_)

    print(paste("-/-/-/-/-/-/-/-/-/", sp_name, km_, "-/-/-/-/-/-/-/-/-/-/-/"))
    # Params ------------------------------------------------------------------
    if (file.exists(paste0(path_cal, "/Final_Models_evaluation/fm_evaluation_results.csv"))) {
      # Params ------------------------------------------------------------------

      fmod_dir <-
        paste0(path_cal, "/Final_models")

      format <- "asc"
      project <- TRUE
      stats <- c("med", "range")
      rep <- TRUE
      scenarios <-
        c(
          "Current", "future_layer_can_126_60",
          "future_layer_can_585_60",
          "future_layer_mc_126_60",
          "future_layer_mc_585_60"
        )

      ext_type <- c("EC")

      out_dir <-
        paste0(path_cal, "/Final_Model_Stats")

      occ_joint <-
        paste0(path_specie, "/", sp_name, "_joint.csv")

      thres <- 50

      curr <- "Current"

      emi_scenarios <- c("126_60", "585_60")

      c_mods <- c("future_layer_can", "future_layer_mc")

      out_dir1 <- paste0(path_cal, "/Projection_Changes")

      kuenm_modstats(
        sp.name = sp_name, fmod.dir = fmod_dir,
        format = format, project = project,
        statistics = stats, replicated = rep,
        proj.scenarios = scenarios,
        ext.type = ext_type, out.dir = out_dir
      )

      # project changes ---------------------------------------------------------

      kuenm_projchanges(
        occ = occ_joint, fmod.stats = out_dir, threshold = thres, current = curr,
        emi.scenarios = emi_scenarios, clim.models = c_mods, ext.type = ext_type,
        out.dir = out_dir1
      )
    } else {
      print(paste("File in", sp_name, "-", km, "don't exist"))
    }
  }
}
