# Libraries ----

library(sf)
library(dplyr)
library(here)
library(units)

# Data ----

protected  <- st_read(here("dataset/spain_protected_areas.gpkg"))
study_area <- st_read(here("dataset/study_area.gpkg"))

# CRS métrico ----

crs_metros <- 25830

protected  <- st_transform(protected, crs_metros)
study_area <- st_transform(study_area, crs_metros)

# Hacer válida la geometría ----

#protected <- st_make_valid(protected)
#study_area <- st_make_valid(study_area)

# Exportar arreglada la geometría ----

#st_write(protected, here("dataset/spain_protected_areas.gpkg"), delete_dsn = TRUE)
#st_write(study_area, here("dataset/study_area.gpkg"), delete_dsn = TRUE)

# Carpeta distribuciones ----

distribution_folder <- here("dataset/distribution_species")

distribution_files <- list.files(
  distribution_folder,
  pattern = "\\.gpkg$",
  full.names = TRUE
)

# Lista vacía para guardar resultados ----

results_list <- list()

# Bucle ----

for(file in distribution_files){
  
  # Nombre de la especie (sin extensión y sin el prefijo)
  species_name <- tools::file_path_sans_ext(basename(file))
  
  species_name <- gsub("distribution_", "", species_name)
  
  cat("Procesando:", species_name, "\n")
  
  # Leer distribución
  sp_distribution <- st_read(file, quiet = TRUE)
  
  # Reproyectar
  sp_distribution <- st_transform(sp_distribution, crs_metros)
  
  # Disolver geometrías
  presencia_dissolve <- st_union(sp_distribution)
  
  # Intersección con áreas protegidas
  sp_protected <- st_intersection(presencia_dissolve, protected)
  
  # Áreas
  area_total <- st_area(presencia_dissolve)
  
  area_protected <- st_area(sp_protected)
  
  # Pasar a numérico
  area_total_m2 <- as.numeric(area_total)
  
  area_protected_m2 <- sum(as.numeric(area_protected))
  
  # Porcentaje protegido
  protected_percent <- (area_protected_m2 / area_total_m2) * 100
  
  # Guardar resultados
  results_list[[species_name]] <- data.frame(
    species = species_name,
    area_total_km2 = round(area_total_m2 / 1e6, 2),
    area_protected_km2 = round(area_protected_m2 / 1e6, 2),
    protected_percent = round(protected_percent, 2)
  )
}

# Unir resultados ----

results_df <- bind_rows(results_list)

# Exportar resultados ----

write.csv(
  results_df,
  here("dataset", "species_protection_summary.csv"),
  row.names = FALSE
)

# Calcular porcentaje protegido de España ----

spain_protected <- st_union(protected)
area_spain_protected <- st_area(spain_protected)
area_spain <- st_area(st_union(study_area))
spain_protected_percent <- (as.numeric(area_spain_protected) / as.numeric(area_spain)) * 100

# Mostrar resultado España

cat(
  "\nPorcentaje protegido de España:",
  round(spain_protected_percent, 2),
  "%\n"
)

# Ver tabla
results_df
