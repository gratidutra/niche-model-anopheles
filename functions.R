dir_create <- function(dir_name) {
  if (!file.exists(dir_name)) {
    dir.create(dir_name)
    print("diretório criado")
  } else {
    print("diretório já existe")
  }
}
