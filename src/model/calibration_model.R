library(kuenm)
                                     
species_list <- c(
  "Anopheles_albimanus", "Anopheles_albitarsis", "Anopheles_apicimacula",
  "Anopheles_aquasalis", "Anopheles_argyritarsis", "Anopheles_braziliensis",
  "Anopheles_darlingi", "Anopheles_eiseni", "Anopheles_evansae", "Anopheles_intermedius",
  "Anopheles_mediopunctatus", "Anopheles_nuneztovari", "Anopheles_oswaldoi",
  "Anopheles_peryassui", "Anopheles_pseudopunctipennis", "Anopheles_punctimacula",
  "Anopheles_rangeli", "Anopheles_strodei", "Anopheles_triannulatus"
)

buffer_area_list <- c(100, 200, 250, 300, 400, 500)

maxent_path <- getwd()

for (specie in seq_along(species_list)) {
  for (km in seq_along(buffer_area_list)) {
    
    sp_name <-species_list[[specie]]
    buffer <- buffer_area_list[[km]]
    
    path_specie <- paste0("data/workflow_maxent/", sp_name)
    path_cal <- paste0(path_specie, "/km_", buffer)

    print(paste('/-/-/-/-/-/-/-/-/-/-/-/-', sp_name, buffer, '/-/-/-/-/-/-/-/-/-/-/-/-'))
    # Params ------------------------------------------------------------------
    occ_joint <-
      paste0(path_specie, "/", sp_name, "_joint.csv")
    
    occ_tra <-
      paste0(path_specie, "/", sp_name, "_train.csv")
    
    M_var_dir <-
      paste0(path_cal, "/Model_calibration/M_variables")
    
    batch_cal <-
      paste0(path_cal, "/Candidate_models")
    
    out_dir <-
      paste0(path_cal, "/Candidate_Models")
    
    out_dir <-
      paste0(path_cal, "/Candidate_Models")
    
    reg_mult <-
      c(seq(0.1, 1, 0.1), seq(2, 6, 1), 8, 10)
    
    f_clas <- "all"
    
    args <- NULL
    
    wait <- FALSE
    
    run <- TRUE
    
    occ_test <-
      paste0(path_specie, "/", sp_name, "_test.csv")
    
    out_eval <-
      paste0(path_cal, "/Calibration_results")
    
    threshold <- 5
    
    rand_percent <- 50
    
    iterations <- 100
    
    kept <- TRUE
    
    selection <- "OR_AICc"
    

    # Model Calibration -------------------------------------------------------

    kuenm_cal(
      occ.joint = occ_joint, occ.tra = occ_tra, M.var.dir = M_var_dir,
      batch = batch_cal, out.dir = out_dir, reg.mult = reg_mult,
      f.clas = f_clas, args = args, maxent.path = maxent_path,
      wait = wait, run = run
    )
    
    #-----------------------Model evaluating models---------------------------------
    
    kuenm_ceval(
      path = out_dir, occ.joint = occ_joint, occ.tra = occ_tra,
      occ.test = occ_test, batch = batch_cal, out.eval = out_eval,
      threshold = threshold, rand.percent = rand_percent,
      iterations = iterations, kept = kept, selection = selection
    )
  }
}