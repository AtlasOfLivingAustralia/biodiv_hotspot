# Finds IBRA regions that correspond to the Forests of East Australia hotspot 

ea_hotspot <- st_read(here("data",
                           "spatial",
                           "hotspots_2016_1",
                           "hotspots_2016_1.shp")) |>
  filter(NAME == "Forests of East Australia")
                         
ibra <- st_read(here("data",
                     "spatial",
                     "ibra7",
                     "ibra7_regions.shp")) |> 
  st_transform(4326)

ibra |> 
  st_intersection(ea_hotspot) |> 
  select(REG_NAME_7) |> 
  saveRDS(here("data",
               "spatial",
               "ibra_hotspot.RDS"))
