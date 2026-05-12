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

# Checking CRS----

st_crs(protected)
st_crs(h.squamatum)
st_crs(f.loscosii)
st_crs(study_area)

protected <- st_transform(protected, 25830)
h.squamatum <- st_transform(h.squamatum, 25830)
study_area <- st_transform(study_area, 25830)
f.loscosii <- st_transform(f.loscosii, 25830)

# Fixing errors----
## Para evitar errores, inconsistencias o comportamientos inesperados en las operaciones espaciales
## cuando se trabaja con coordenadas geográficas. Transforma de esférico a plano.
sf_use_s2(FALSE)

# Analysis----
## Create distribution area for each specie
## Tenemos que generar una capa de cuadrículas con el área de cada especie, de 100x100 metros?
## Si cae dentro de esa cuadrícula de 100x100 un punto, mantenemos la cuadrícula,
## así se genera una capa con la dsitribución y podemos ver mejor el área dentro de espacios protegidos.

grid <- st_make_grid(
  f.loscosii,
  cellsize = 100,
  square = TRUE
)

grid_sf <- st_sf(geometry = grid)
grid_presencia <- grid_sf[lengths(st_intersects(grid_sf, f.loscosii)) > 0, ]

# plot
ggplot() +
  geom_sf(data = grid_sf, fill = NA, color = "grey80", linewidth = 0.2) +
  geom_sf(data = f.loscosii, color = "red", size = 1.5) +
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



