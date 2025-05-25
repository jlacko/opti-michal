library(sf)
library(dplyr)
library(sfnetworks)

cesta <- "./data/grid_MC_rot.gpkg"

# načíst metadata
con <- DBI::dbConnect(RSQLite::SQLite(), cesta) # připojit databázi

metadata <- DBI::dbReadTable(con, "metadata")

DBI::dbDisconnect(con)
rm(con)

cena_stavby <- function(prevyseni) {
   
   # převýšení do 12 promile cajk, jinak totální penalta
   case_when(prevyseni == 0 ~ 1/2,
             prevyseni <= 0.012 * metadata$value[metadata$code == "roztec"] ~ prevyseni,
             T ~ Inf)
   
}


# načíst objekty
uzly <- st_read(cesta, layer = "centroidy")
hrany <- st_read(cesta, layer = "spojnice") %>% 
   mutate(cena_stavby = cena_stavby(prevyseni))

sit <- sfnetwork(uzly, hrany, directed = F, force = T) # bacha: bez force (eliminace kontroly) padá na memory

saveRDS(sit, paste0(fs::path_ext_remove(cesta), ".rds"))