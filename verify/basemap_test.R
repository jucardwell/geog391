library(sf); library(tmap); library(maptiles)
cat("tmap", as.character(packageVersion("tmap")), "maptiles", as.character(packageVersion("maptiles")), "\n")
acs <- st_read("data/nc_tract_acs_2023.geojson", quiet = TRUE)
meck <- acs[acs$COUNTYFP == "119", ]
tmap_mode("plot")
for (p in c("CartoDB.PositronNoLabels", "CartoDB.Positron", "Esri.WorldGrayCanvas", "Esri.WorldTopoMap", "OpenStreetMap", "Esri.WorldStreetMap")) {
  cat("\n=====", p, "\n")
  t1 <- tryCatch({ r <- get_tiles(meck, provider = p, zoom = 10, crop = TRUE); paste("get_tiles ok, cells:", terra::ncell(r), "mean value:", round(mean(terra::values(r), na.rm = TRUE), 1)) },
                 error = function(e) paste("get_tiles ERROR:", conditionMessage(e)), warning = function(w) paste("get_tiles WARNING:", conditionMessage(w)))
  cat(t1, "\n")
  png(paste0("bm_", p, ".png"), 900, 700)
  msgs <- character()
  res <- withCallingHandlers(tryCatch({ print(tm_shape(meck) + tm_polygons(fill_alpha = 0.3) + tm_basemap(p)); "printed" }, error = function(e) paste("ERROR:", conditionMessage(e))),
                             message = function(m) { msgs <<- c(msgs, conditionMessage(m)); invokeRestart("muffleMessage") },
                             warning = function(w) { msgs <<- c(msgs, paste("WARN", conditionMessage(w))); invokeRestart("muffleWarning") })
  dev.off()
  cat("tmap:", res, "\n"); if (length(msgs)) cat("messages:", msgs, sep = "\n  ")
}
