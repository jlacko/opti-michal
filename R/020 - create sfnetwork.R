library(sf)
library(dplyr)
library(sfnetworks)


# načíst metadata
con <- DBI::dbConnect(RSQLite::SQLite(), "./data/grid.gpkg") # připojit databázi

metadata <- DBI::dbReadTable(con, "metadata")

DBI::dbDisconnect(con)
rm(con)

cena_stavby <- function(prevyseni) {
   
   # převýšení do 12 promile cajk, jinak totální penalta
   case_when(prevyseni == 0 ~ 1/2,
             prevyseni <= 0.012 * metadata$value[metadata$code == "roztec"] ~ prevyseni,
             T ~ 1000)
   
}


# načíst objekty
uzly <- st_read("./data/grid.gpkg", layer = "centroidy")
hrany <- st_read("./data/grid.gpkg", layer = "spojnice") %>% 
   mutate(cena_stavby = cena_stavby(prevyseni))

sit <- sfnetwork(uzly, hrany, directed = F)


saveRDS(sit, "./data/network.rds")