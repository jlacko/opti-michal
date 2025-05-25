library(sf)
library(dplyr)
library(sfnetworks)

sit <- readRDS("./data/grid_MC_rot.rds")

# index uzlů nejbližších k zadané adrese
idx_pocatek <- 1

idx_cil <- 1024

# start a cíl jako body v síti
start <- st_geometry(sit, "nodes")[idx_pocatek] 
cil <- st_geometry(sit, "nodes")[idx_cil]

# benchmark - 100× pustit, a zjistit průměr / medián
microbenchmark::microbenchmark(
   # cesta jako sekvence uzlů
   cesta_numericky <- st_network_paths(sit,
                                       from = start, 
                                       to = cil, 
                                       # alternativy: vzdalenost / prevyseni / cena_stavby
                                       weights = "cena_stavby")

, times = 100) %>% print()

# cesta jako sekvence hran / podle sekvence uzlů...
cesta_graficky <- sit %>%
   activate("nodes") %>% 
   slice(cesta_numericky$node_paths[[1]]) %>% 
   activate("edges") %>% 
   st_as_sf()

# vzdálenost "as the crow flies"
st_distance(start, cil, by_element = TRUE)

# vzdálenost po cestě
sum(st_length(cesta_graficky))

# o výsledku podat zprávu
plot(st_geometry(cesta_graficky))

st_read("./data/grid_MC_rot.gpkg", layer = "centroidy")[cesta_numericky$node_paths[[1]],]