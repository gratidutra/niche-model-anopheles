diretorio="data/workflow_maxent" # Substitua pelo caminho do diretório que deseja verificar

if [ -d "$diretorio" ]; then
  for pasta in "$diretorio"/*; do
    if [ -d "$pasta" ]; then
      old_file="${pasta}/km_250/MOP_ntbox/Set_1/future_layer_mc_126_60.tif"
      new_file="${pasta}/km_250/MOP_ntbox/Set_1/MOP_10%_future_layer_mc_126_60.tif"
      if [ -f "$old_file" ]; then
        mv "$old_file" "$new_file"
      else
        echo "File $old_file does not exist."
      fi
    else
      echo "$pasta is not a directory."
    fi
  done
else
  echo "Directory $diretorio does not exist."
fi
