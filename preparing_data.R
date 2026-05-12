# Libraries----

library(sf)
library(dplyr)
library(ggplot2)
library(here)

# Data----

protected <- st_read(here("dataset/spain_protected_areas.gpkg"))
h.squamatum <- st_read(here("dataset/helianthemum_squamatum.gpkg"))
study_area <- st_read(here("dataset/study_area.gpkg"))

# Checking CRS----

st_crs(protected)
st_crs(h.squamatum)
st_crs(study_area)


protected <- st_make_valid(protected)
# Analysis----
## Which points of h.sq are inside a protected area??
inside <- st_intersects(h.squamatum, protected)
