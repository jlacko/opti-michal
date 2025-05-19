# rozšířit grid o vstupy pro matici

library(sf)
library(dplyr)

# sudé mocniny dvojky
plochy <- c(2^(2*5))

for (plocha in plochy) {
   
   # iterace po velikostech
   cesta <- paste0("./data/grid_", plocha,".gpkg")
   

   # načíst metadata
   con <- DBI::dbConnect(RSQLite::SQLite(), cesta) # připojit databázi
   
   metadata <- DBI::dbReadTable(con, "metadata")
   
   DBI::dbDisconnect(con)
   rm(con)
   
   # načíst data - centroidy stačí
   centroidy <- st_read(cesta,
                        "centroidy",
                        fid_column_name = "grid_id")
   
   # šířka matice výškopisů
   sirka_matice <- metadata %>% 
      filter(code == "sirka") %>% 
      pull(value)
   
   # rozteč matice výškopisů
   roztec_matice <- metadata %>% 
      filter(code == "roztec") %>% 
      pull(value)
   
   # sauber machen - vyčistit!
   st_delete(cesta, layer = "spojnice")
   
   zaloz_spojnici <- function(from, to) {
      
      # atomické složky
      wrk_from <- from
      wrk_to <- to
      prevyseni <- abs(centroidy$vyska[from] - centroidy$vyska[to])
      cara <- st_sfc(st_linestring(c(centroidy$geom[from][[1]], centroidy$geom[to][[1]])))
      
      # výstup - leze z fce ven...
      data.frame(from = wrk_from,
                 to = wrk_to,
                 vzdalenost = roztec_matice,
                 prevyseni = prevyseni,
                 geom = cara) %>% 
         st_as_sf(crs = st_crs(centroidy))
      
   }
   
   for (node in centroidy$grid_id) {
      
     
      # indexy buněk
      aktualni <- which(centroidy$grid_id == node)
      o_misto <- pmin(aktualni + 1, nrow(centroidy))
      o_radu <- pmin(aktualni + sirka_matice, nrow(centroidy))
      
      # jednou za čas ET call home
      if (aktualni %% 250 == 0) cat(paste(Sys.time(),
                                          "Zpráva z krizového vývoje:",
                                          aktualni,
                                          "done;",
                                          nrow(centroidy) - aktualni,
                                          "to go...\n"))
      
      
      # má cenu založit o místo? = máme příští pozici, a nejsme v posledním sloupci?
      if (o_misto > aktualni & !aktualni %% sirka_matice == 0 ) {
         
         st_write(zaloz_spojnici(aktualni, o_misto),
                  dsn = cesta,
                  layer = "spojnice",
                  append = TRUE,
                  quiet = TRUE)
      }
      
      # má cenu založit o řádek? = máme příští pozici, a nejsme v posledním řádku?
      if (o_radu > aktualni & aktualni <= (nrow(centroidy) - sirka_matice)) {
         
         st_write(zaloz_spojnici(aktualni, o_radu),
                  dsn = cesta,
                  layer = "spojnice",
                  append = TRUE,
                  quiet = TRUE)
      }
   }
}