library(sf)
library(dplyr)
library(sfnetworks)

sit <- readRDS("./data/network.rds")

# index uzlů nejbližších k zadané adrese
idx_pocatek <- RCzechia::geocode("Sokolovská 663/136c, Karlín, 18600 Praha 8") %>% 
   st_transform(st_crs(sit)) %>% 
   st_nearest_feature(sit)

idx_cil <- RCzechia::geocode("Vladivostocká 1460/10b, Vršovice, 10000 Praha 10") %>% 
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
                                    weights = "vzdalenost")

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

# o výsledkku podat zprávu
mapview::mapview(cesta_graficky)