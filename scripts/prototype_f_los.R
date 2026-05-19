# Libraries----

library(sf)
library(dplyr)
library(ggplot2)
library(here)

# Data----

protected <- st_read(here("dataset/spain_protected_areas.gpkg"))
study_area <- st_read(here("dataset/study_area.gpkg"))
flos <- st_read(here("dataset/species/ferula_loscosii.gpkg"))
#peninsula <- st_read(here("dataset/peninsula.gpkg"))

# Checking CRS----

st_crs(protected)
st_crs(flos)
st_crs(study_area)


protected <- st_transform(protected, 25830)
study_area <- st_transform(study_area, 25830)
flos <- st_transform(flos, 25830)

## Reproyectar a un CRS métrico----
crs_metros <- 25830   # ETRS89 / UTM 30N

flos <- st_transform(flos, crs_metros)
study_area <- st_transform(study_area, crs_metros)
#peninsula <- st_transform(peninsula, crs_metros)
protected <- st_transform(protected, crs_metros)

## Crear rejilla SOLO sobre los puntos de la sp.

# F. LOSCOSII
grid <- st_make_grid(
  flos,
  cellsize = 1000,
  square = TRUE
)

## Convertir la rejilla en sf
grid_sf <- st_sf(id = 1:length(grid), geometry = grid)

## Seleccionar solo cuadrículas con presencia

grid_presencia_flos <- st_join(
  grid_sf,
  flos,
  join = st_intersects,
  left = FALSE
)

## Eliminamos cuadrículas duplicadas
grid_presencia_flos <- grid_presencia_flos |> 
  distinct(id, .keep_all = TRUE)

## Recortamos al mapa de España
grid_presencia_flos <- st_intersection(grid_presencia_flos, study_area)

## Representamos
#plot(st_geometry(peninsula), col = "grey95")

#plot(
  #st_geometry(grid_presencia),
  #col = "red",
  #border = "red",
  #add = TRUE
#)

# Exportar capa presencia

grid_presencia_flos <- st_sf(geometry = st_geometry(grid_presencia_flos))

st_write(
  grid_presencia_flos,
  here("dataset/distribution_species", "distribution_flos.gpkg"),
  delete_dsn = TRUE
)

## Necesito crear un bucle que tome los .gpkg de los puntos de las sp. 
# y me devuelva todas las capas de distribución de cada especie y
# me las guarde en una carpeta que agrupe todas las distribuciones de las especies.

## Después debo crear otro bucle que tome esos .gpkg y me calcule el grado de solapamiento con
# las zonas protegidas de España, en una especie de lista para poder visualizarlo mejor.
# Quizás en un .csv


## Solapamiento----
# Primero disolvemos las cuadrículas y luego ya calculamos

presencia_dissolve <- st_union(grid_presencia_flos)
flos_protected <- st_intersection(presencia_dissolve, protected)
area_total <- st_area(presencia_dissolve)
area_protegida <- st_area(flos_protected)
porcentaje <- (area_protegida / area_total) * 100
as.numeric(porcentaje)

# ¿Qué porcentaje de España se encuentra protegida?

spain_protected <- st_area(protected)
area_spain <- st_area(study_area)

porcentaje <- (
  spain_protected / area_spain
) * 100

as.numeric(porcentaje)
