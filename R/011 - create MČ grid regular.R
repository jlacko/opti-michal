library(sf)
library(dplyr)
library(terra)

src <- list()

src$x <- seq(0,by=1,len=64)
src$y <- seq(0,by=1,len=64)
src$z <- matrix(100 * rep(c(1, 1:63 * .13),64),64,64)


rast <- terra::rast(src)

outline <- st_point(x = c(32, 32)) %>% 
   st_buffer(16) %>% 
   st_bbox() %>% 
   st_as_sfc()

plot(rast)
plot(outline, add = T)

# equal area grid - kilometřík je dobrá míra...
grid <- outline %>% 
   st_make_grid(cellsize = 1) %>% 
   st_as_sf() %>% 
   mutate(grid_id = 1:n())

plot(rast)
plot(st_geometry(grid), add = T)

# průměrná výška gridu v metrech nad mořem
grid$vyska <- exactextractr::exact_extract(
   x = rast,
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
          value = pocet ) %>% 
   select(code, value) %>% 
   bind_rows(data.frame(code = "roztec", value = 100))


# https://r.geocompx.org/geometry-operations#affine-transformations
rotation = function(a){
   r = a * pi / 180 #degrees to radians
   matrix(c(cos(r), sin(r), -sin(r), cos(r)), nrow = 2, ncol = 2)
} 

grid_rot <- (st_geometry(grid) - st_centroid(outline)) * rotation(45) + st_centroid(outline) 

plot(rast)
plot(st_geometry(grid_rot), add = T)


grid_rot <- grid_rot %>% 
   st_as_sf() %>% 
   mutate(grid_id = 1:n())

# průměrná výška gridu v metrech nad mořem
grid_rot$vyska <- exactextractr::exact_extract(
   x = rast,
   y = grid_rot, 
   fun = "mean" 
) 

cesta <- paste0("./data/grid_MC_bas.gpkg")

# středy čtverečků
centroids <- grid %>% 
   st_centroid()

# uložit grid
st_write(grid, cesta, 
         layer = "ctverecky", 
         append = FALSE,
         fid_column_name = "grid_id")

# uložit středy
st_write(centroids, cesta, 
         layer = "centroidy", 
         append = FALSE,
         fid_column_name = "grid_id")


# zapsat rozměry
library(DBI)

con <- DBI::dbConnect(RSQLite::SQLite(), cesta) # připojit databázi

# zahodit co bylo...
dbExecute(con, "drop table if exists metadata;")
# uložit do databáze
DBI::dbWriteTable(con, "metadata", vzdalenosti)

DBI::dbDisconnect(con)

cesta <- paste0("./data/grid_MC_rot.gpkg")

# středy čtverečků
centroids <- grid_rot %>% 
   st_centroid()

# uložit grid
st_write(grid_rot, cesta, 
         layer = "ctverecky", 
         append = FALSE,
         fid_column_name = "grid_id")

# uložit středy
st_write(centroids, cesta, 
         layer = "centroidy", 
         append = FALSE,
         fid_column_name = "grid_id")


# zapsat rozměry
library(DBI)

con <- DBI::dbConnect(RSQLite::SQLite(), cesta) # připojit databázi

# zahodit co bylo...
dbExecute(con, "drop table if exists metadata;")
# uložit do databáze
DBI::dbWriteTable(con, "metadata", vzdalenosti)

DBI::dbDisconnect(con)

