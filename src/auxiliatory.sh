diretorio="data/workflow_maxent/Anopheles_darlingi" # Substitua pelo caminho do diretório que deseja verificar

if [ -d "$diretorio" ]; then
      scp -P 2200 -r $diretorio/km_*/Model_calibration/ grati@200.132.101.178:~/niche-model-anopheles/$diretorio/km_* 
      echo 'ok'
fi
