# výškopis města Prahy jako "raster" pro vstup modelace

library(RCzechia)
library(dplyr)
library(sf)

velikost <- units::set_units(1, "km2")

# obrysy Prahy - v metrickém CRS
praha <- kraje() %>% 
   filter(KOD_CZNUTS3 == "CZ010") %>% 
   st_transform(3035)

# equal area grid - kilometřík je dobrá míra...
grid <- praha %>% 
   st_make_grid(cellsize = velikost) %>% 
   st_as_sf() %>% 
   mutate(grid_id = 1:n())

# 

# průměrná výška gridu v metrech nad mořem
grid$vyska <- exactextractr::exact_extract(
   x = vyskopis("actual"), 
   y = grid, 
   fun = "mean" 
) 

# vzdálenost rohů gridu = dimenze matice buněk
vzdalenosti <- grid %>%
   summarise() %>%
   st_simplify() %>%
   st_cast("POINT") %>%
   unique() %>%
   st_distance() %>% 
   .[1, c(2, 4)] %>%  
   as.data.frame() %>% 
   rename(pocet = '.') %>% 
   mutate(code = c("sirka", "delka"),
          value = units::drop_units(pocet / sqrt(velikost))) %>% 
   select(code, value) %>% 
   bind_rows(data.frame(code = "roztec", value = units::drop_units(units::set_units(sqrt(velikost), "m"))))

# středy čtverečků
centroids <- grid %>% 
   st_centroid()

# uložit grid
st_write(grid, "./data/grid.gpkg", 
         layer = "ctverecky", 
         append = FALSE,
         fid_column_name = "grid_id")

# uložit středy
st_write(centroids, "./data/grid.gpkg", 
         layer = "centroidy", 
         append = FALSE,
         fid_column_name = "grid_id")


# zapsat rozměry
library(DBI)

con <- DBI::dbConnect(RSQLite::SQLite(), "./data/grid.gpkg") # připojit databázi

# zahodit co bylo...
dbExecute(con, "drop table if exists metadata;")
# uložit do databáze
DBI::dbWriteTable(con, "metadata", vzdalenosti)

DBI::dbDisconnect(con)

