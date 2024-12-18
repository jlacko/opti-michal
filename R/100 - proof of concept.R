library(sf)
library(dplyr)
library(sfnetworks)


uzly <- st_read("./data/grid.gpkg", layer = "centroidy")
hrany <- st_read("./data/grid.gpkg", layer = "spojnice")

sit <- sfnetwork(uzly, hrany, directed = F)

# index uzlů nejbližších k zadané adrese
idx_pocatek <- RCzechia::geocode("náměstí Winstona Churchilla 1938/4, Praha 3") %>% 
   st_transform(st_crs(sit)) %>% 
   st_nearest_feature(sit)

idx_cil <- RCzechia::geocode("Ke Karlovu 2027/3, Praha 2") %>% 
   st_transform(st_crs(sit)) %>% 
   st_nearest_feature(sit)

# start a cíl jako body v síti
start <- st_geometry(sit, "nodes")[idx_pocatek] 
cil <- st_geometry(sit, "nodes")[idx_cil]


# cesta jako sekvence uzlů
cesta_numericky <- st_network_paths(sit,
                                    from = start, 
                                    to = cil, 
                                    # alternativy: vzdalenost / prevyseni
                                    weights = "prevyseni")

# cesta jako sekvence hran / podle sekvence uzlů...
cesta_graficky <- sit %>%
   activate("nodes") %>% 
   slice(cesta_numericky$node_paths[[1]]) %>% 
   activate("edges") %>% 
   st_as_sf()


# o výsledkku podat zprávu
mapview::mapview(cesta_graficky)