library(sf)
library(dplyr)
library(sfnetworks)

sit <- readRDS("./data/network.rds")

# index uzlů nejbližších k zadané adrese
#idx_pocatek <- RCzechia::geocode("Sokolovská 49/83, Karlín, 18600 Praha 8") %>% 
idx_pocatek <- RCzechia::geocode("Milady Horákové 1066/98, Bubeneč, 17000 Praha 7") %>% 
   st_transform(st_crs(sit)) %>% 
   st_nearest_feature(sit)

#idx_cil <- RCzechia::geocode("Ke Karlovu 2027/3, Nové Město, 12000 Praha 2") %>% 
idx_cil <- RCzechia::geocode("U Slavie 1540/2a, Vršovice, 10000 Praha 10") %>%
   st_transform(st_crs(sit)) %>% 
   st_nearest_feature(sit)

# start a cíl jako body v síti
start <- st_geometry(sit, "nodes")[idx_pocatek] 
cil <- st_geometry(sit, "nodes")[idx_cil]


# cesta jako sekvence uzlů
cesta_numericky <- st_network_paths(sit,
                                    from = start, 
                                    to = cil, 
                                    # alternativy: vzdalenost / prevyseni / cena_stavby
                                    weights = "cena_stavby")

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