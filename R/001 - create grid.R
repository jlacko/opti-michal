# výškopis města Prahy jako "raster" pro vstup modelace

library(RCzechia)
library(dplyr)
library(sf)

# centrální Praha = okolí ÚV KSČ
praha <- RCzechia::geocode("Politických vězňů 1531/9, Nové Město, 11000 Praha 1") %>% 
   st_transform(3035) %>% 
   st_buffer(units::set_units(4, "km")) %>% 
   st_bbox() %>% 
   st_as_sfc()


# rastery z RCzechia - hrana pixelu = 25m
dolni <- terra::rast("~/Documents/RCzechia/data-raw/eu_dem_v11_E40N20.TIF")
horni <- terra::rast("~/Documents/RCzechia/data-raw/eu_dem_v11_E40N30.TIF")

celek <- terra::merge(horni, dolni)

# okolí republiky (ne jej)
maska <- praha %>%
   st_bbox() %>%
   st_as_sfc() %>%
   st_transform(st_crs(celek)) 

# pozor! macík... dál už trifka
cast <- terra::crop(celek, maska, mask = T)

# sudé mocniny dvojky
plochy <- c(2^(2*0:5))

for (plocha in plochy) {
   
   # iterace po velikostech
   velikost <- units::set_units(1/plocha, "km2") # 1/256 ještě funguje dobře
   cesta <- paste0("./data/grid_", plocha,".gpkg")
   
   # equal area grid - kilometřík je dobrá míra...
   grid <- praha %>% 
      st_make_grid(cellsize = velikost) %>% 
      st_as_sf() %>% 
      mutate(grid_id = 1:n())
   
   
   # průměrná výška gridu v metrech nad mořem
   grid$vyska <- exactextractr::exact_extract(
   #   x = vyskopis("actual"), # z RCzechia - hrana pixelu = 100m
      x = cast,
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

}