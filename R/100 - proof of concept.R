library(sf)
library(dplyr)
library(sfnetworks)


uzly <- st_read("./data/grid.gpkg", layer = "centroidy")
hrany <- st_read("./data/grid.gpkg", layer = "spojnice")

sit <- sfnetwork(uzly, hrany, directed = F)

# start a cíl jako body v síti
start <- st_geometry(sit, "nodes")[509] # 541 = ekonomka; 509 = Eden
cil <- st_geometry(sit, "nodes")[649] # 571 = matfyz; 649 = Balabenka

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