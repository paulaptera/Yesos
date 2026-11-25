# Libraries----

library(sf)
library(dplyr)
library(ggplot2)
library(here)

# Data----

protected <- st_read(here("dataset/spain_protected_areas.gpkg"))
h.squamatum <- st_read(here("dataset/helianthemum_squamatum.gpkg"))
study_area <- st_read(here("dataset/study_area.gpkg"))
f.loscosii <- st_read(here("dataset/ferula_loscosii.gpkg"))
peninsula <- st_read(here("dataset/peninsula.gpkg"))

# Checking CRS----

st_crs(protected)
st_crs(h.squamatum)
st_crs(f.loscosii)
st_crs(study_area)

protected <- st_transform(protected, 25830)
h.squamatum <- st_transform(h.squamatum, 25830)
study_area <- st_transform(study_area, 25830)
f.loscosii <- st_transform(f.loscosii, 25830)

## Reproyectar a un CRS métrico
crs_metros <- 25830   # ETRS89 / UTM 30N

f.loscosii <- st_transform(f.loscosii, crs_metros)
study_area <- st_transform(study_area, crs_metros)
peninsula <- st_transform(peninsula, crs_metros)

## Crear rejilla SOLO sobre los puntos de la sp.

# F. LOSCOSII
grid <- st_make_grid(
  f.loscosii,
  cellsize = 1000,
  square = TRUE
)

## Convertir la rejilla en sf
grid_sf <- st_sf(id = 1:length(grid), geometry = grid)

## Seleccionar solo cuadrículas con presencia

grid_presencia <- st_join(
  grid_sf,
  f.loscosii,
  join = st_intersects,
  left = FALSE
)

## Eliminamos cuadrículas duplicadas
grid_presencia <- grid_presencia |> 
  distinct(id, .keep_all = TRUE)

## Recortamos al mapa de España
grid_presencia <- st_intersection(grid_presencia, peninsula)

## Representamos
plot(st_geometry(peninsula), col = "grey95")

plot(
  st_geometry(grid_presencia),
  col = "red",
  border = "darkred",
  add = TRUE
)

## Exportar capa presencia

st_write(
  grid_presencia,
  here("dataset", "distribution_f.loscosii.gpkg"),
  delete_dsn = TRUE
)

## Solapamiento----

protected <- st_transform(protected, crs_metros)
inter <- st_intersection(grid_presencia, protected)
sum(st_area(inter)) / sum(st_area(grid_presencia))





# Fixing errors----
## Para evitar errores, inconsistencias o comportamientos inesperados en las operaciones espaciales
## cuando se trabaja con coordenadas geográficas. Transforma de esférico a plano.
sf_use_s2(FALSE)

# Analysis----
## Create distribution area for each specie
## Tenemos que generar una capa de cuadrículas con el área de cada especie, de 100x100 metros.
## Si cae dentro de esa cuadrícula de 100x100 un punto, mantenemos la cuadrícula,
## así se genera una capa con la distribución y podemos ver mejor el área dentro de espacios protegidos.

# F. LOSCOSII
grid <- st_make_grid(
  f.loscosii,
  cellsize = 100,
  square = TRUE
)

grid_sf <- st_sf(geometry = grid)
grid_presencia <- grid_sf[lengths(st_intersects(grid_sf, f.loscosii)) > 0, ]

ggplot() +
  geom_sf(data = study_area, fill = "white", color = "black") +
  geom_sf(data = grid_presencia, fill = "red", alpha = 1, color = NA) +
  theme_minimal()

## Which points of h.sq are inside a protected area??
inside <- st_intersects(h.squamatum, protected)
h.squamatum$protected <- lengths(inside) > 0
table(h.squamatum$protected)
mean(h.squamatum$protected)*100

inside <- st_intersects(f.loscosii, protected)
f.loscosii$protected <- lengths(inside) > 0
table(f.loscosii$protected)
f.loscosii_protected <- mean(f.loscosii$protected)*100

## Plotting



