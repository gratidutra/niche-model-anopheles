library(kuenm)
library(tidyverse)

species_list <- c(
    "Anopheles_albitarsis", "Anopheles_apicimacula", 
    "Anopheles_aquasalis","Anopheles_argyritarsis", "Anopheles_braziliensis",
    "Anopheles_darlingi", "Anopheles_eiseni", "Anopheles_evansae", 
    "Anopheles_intermedius", "Anopheles_mediopunctatus", 
    "Anopheles_oswaldoi","Anopheles_peryassui", "Anopheles_pseudopunctipennis", 
    "Anopheles_punctimacula", "Anopheles_rangeli", "Anopheles_strodei", 
    "Anopheles_triannulatus", "Anopheles_rangeli"
  )

buffer_area_list <- c(100, 200, 250, 300, 400, 500)

maxent_path <- getwd()

for (specie in seq_along(species_list)) {
  for (km in seq_along(buffer_area_list)) {
    sp_name <- species_list[[specie]]
    km <- buffer_area_list[[km]]

    print(paste('/-/-/-/-/-/-/-/-/-/-/-/-', sp_name, km, '/-/-/-/-/-/-/-/-/-/-/-/-'))
    
    path_specie <- paste0("data/workflow_maxent/", sp_name)
    path_buffer <- paste0("data/workflow_maxent/", sp_name, '/km_', km)

    # Params ------------------------------------------------------------------
    occ_joint <-
      paste0(path_specie, "/", sp_name, "_joint.csv")

    occ_tra <-
      paste0(path_specie, "/", sp_name, "_train.csv")

    occ_test <-
      paste0(path_specie, "/", sp_name, "_test.csv")

    M_var_dir <-
      paste0(path_buffer, "/Model_calibration/M_variables")

    batch_cal <-
      paste0(path_buffer, "/Candidate_models")

    out_dir <-
      paste0(path_buffer, "/Candidate_Models")

    reg_mult <-
      c(seq(0.1, 1, 0.1), seq(2, 6, 1), 8, 10)

    f_clas <- "all"

    args <- NULL

    wait <- FALSE

    run <- TRUE

    out_eval <-
      paste0(path_buffer, "/Calibration_results")

    threshold <- 5

    rand_percent <- 50

    iterations <- 100

    kept <- TRUE

    selection <- "OR_AICc"

    # dir.create(paste0("data/workflow_maxent/", sp_name, "/Final_models"))

    batch_fin <-
      paste0(path_buffer, "/Final_models")

    mod_dir <-
      paste0(path_buffer, "/Final_models")

    rep_n <- 5

    rep_type <- "Bootstrap"

    jackknife <- TRUE

    out_format <- "logistic"

    project <- TRUE

    G_var_dir <-
      paste0(path_buffer, "/G_variables")

    ext_type <- "all"

    write_mess <- FALSE

    write_clamp <- FALSE

    wait1 <- FALSE

    run1 <- TRUE

    args <- NULL

  kuenm_mod(
      occ.joint = occ_joint, M.var.dir = M_var_dir, out.eval = out_eval,
      batch = batch_fin, rep.n = rep_n, rep.type = rep_type,
      jackknife = jackknife, out.dir = mod_dir, out.format = out_format,
      project = project, G.var.dir = G_var_dir, ext.type = ext_type,
      write.mess = write_mess, write.clamp = write_clamp,
      maxent.path = maxent_path, args = args, wait = wait1, run = run1
    )

    replicates <- TRUE

    out_feval <- paste0(path_buffer, "/Final_Models_evaluation")

    fin_eval <- kuenm_feval(
      path = mod_dir, occ.joint = occ_joint, occ.ind = occ_test, replicates = replicates,
      out.eval = out_feval, threshold = threshold, rand.percent = rand_percent,
      iterations = iterations
    )
  }
}