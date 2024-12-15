# výškopis města Prahy jako "raster" pro vstup modelace

library(RCzechia)
library(dplyr)
library(sf)

# obrysy Prahy - v metrickém CRS
praha <- kraje() %>% 
   filter(KOD_CZNUTS3 == "CZ010") %>% 
   st_transform(3035)

# equal area grid - kilometřík je dobrá míra...
grid <- praha %>% 
   st_make_grid(cellsize = units::set_units(1, "km2")) %>% 
   st_as_sf() %>% 
   mutate(id = 1:n())

# 

# průměrná výška gridu v metrech nad mořem
grid$vyska <- exactextractr::exact_extract(
   x = vyskopis("actual"), 
   y = grid, 
   fun = "mean" 
) 

# vzdálenost rohů gridu = dimenze matice buněk
grid %>%
   summarise() %>%
   st_simplify() %>%
   st_cast("POINT") %>%
   unique() %>%
   st_distance()

# uložit pro budoucí použití...
st_write(grid, "./data/grid.gpkg")