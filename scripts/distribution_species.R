## En este script lo que hacemos es partir de un mapa de puntos .gpkg de GBIF con la distribución de las especies,
# generar una capa con la distribución en cuadrículas .gpkg de cada especie. Esta cuadrícula se genera cuando caen uno
# o más puntos dentro de ella.

# Libraries ----

library(sf)
library(dplyr)
library(here)

# Data base ----

protected <- st_read(here("dataset/spain_protected_areas.gpkg"))
study_area <- st_read(here("dataset/study_area.gpkg"))

# CRS métrico ----

crs_metros <- 25830

protected  <- st_transform(protected, crs_metros)
study_area <- st_transform(study_area, crs_metros)

# Carpeta de entrada y salida ----

input_folder  <- here("dataset/species")
output_folder <- here("dataset/distribution_species")

# Lista de archivos .gpkg ----

species_files <- list.files(
  input_folder,
  pattern = "\\.gpkg$",
  full.names = TRUE
)

# Bucle ----

for(file in species_files){
  
  # Nombre de la especie (sin extensión)
  species_name <- tools::file_path_sans_ext(basename(file))
  
  cat("Procesando:", species_name, "\n")
  
  # Leer capa
  sp <- st_read(file, quiet = TRUE)
  
  # Reproyectar
  sp <- st_transform(sp, crs_metros)
  
  # Crear rejilla
  grid <- st_make_grid(
    sp,
    cellsize = 1000,
    square = TRUE
  )
  
  # Convertir a sf
  grid_sf <- st_sf(
    id = 1:length(grid),
    geometry = grid
  )
  
  # Seleccionar cuadrículas con presencia
  grid_presence <- st_join(
    grid_sf,
    sp,
    join = st_intersects,
    left = FALSE
  )
  
  # Eliminar duplicados
  grid_presence <- grid_presence |>
    distinct(id, .keep_all = TRUE)
  
  # Recortar al área de estudio
  grid_presence <- st_intersection(
    grid_presence,
    study_area
  )
  
  # Mantener solo geometría
  grid_presence <- st_sf(
    geometry = st_geometry(grid_presence)
  )
  
  # Nombre de salida
  output_name <- paste0(
    "distribution_",
    species_name,
    ".gpkg"
  )
  
  # Exportar
  st_write(
    grid_presence,
    here(output_folder, output_name),
    delete_dsn = TRUE,
    quiet = TRUE
  )
  
  cat("Guardado:", output_name, "\n\n")
}

cat("Proceso completado.\n")