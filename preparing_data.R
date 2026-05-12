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

# Fixing errors----
## Para evitar errores, inconsistencias o comportamientos inesperados en las operaciones espaciales
## cuando se trabaja con coordenadas geográficas. Transforma de esférico a plano.
sf_use_s2(FALSE)

# Analysis----
## Create distribution area for each specie
## Tenemos que generar una capa de cuadrículas con el área de cada especie, de 100x100 metros?
## Si cae dentro de esa cuadrícula de 100x100 un punto, mantenemos la cuadrícula,
## así se genera una capa con la dsitribución y podemos ver mejor el área dentro de espacios protegidos.

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



