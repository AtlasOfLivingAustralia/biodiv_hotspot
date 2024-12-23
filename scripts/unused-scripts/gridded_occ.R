# spatial bits -------

# equal area projection
aus_map <- st_transform(ozmap_country, crs = 3577)

# 10 by 10 km grid
aus_grid <- st_make_grid(aus_map, 
                         cellsize = c(10000, 10000),
                         square = TRUE) 

# grid clipped to terrestrial only
aus_grid_clipped <- aus_grid |> 
  st_intersection(st_geometry(aus_map)) |>  
  st_as_sf() |> 
  st_set_geometry("grid_geometry") |> 
  tibble::rowid_to_column(var = "grid_id")
  
# hotspot
ea_hotspot <- st_read(here("data",
                           "spatial",
                           "hotspots_2016_1",
                           "hotspots_2016_1.shp")) |>
  filter(NAME == "Forests of East Australia") |> 
  st_transform(crs = 3577)

# species bits --------- 
# dragon occ
ewd <- galah_call() |> 
  identify("https://biodiversity.org.au/afd/taxa/5299e126-2198-4726-8c5d-afc1eb6c8921") |> 
  galah_apply_profile(ALA) |> 
  filter(year >= 1950, 
         countryCode == "AU",
         !is.na(decimalLatitude), 
         !is.na(decimalLongitude)) |> 
  select(species, 
         decimalLatitude, 
         decimalLongitude, 
         year, 
         cl1048) |> 
  atlas_occurrences()

ewd_sf <- st_as_sf(ewd, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326) |>
  st_transform(crs = 3577)

ewd_with_grid <- st_join(ewd_sf, aus_grid_clipped)
# ewd occurs in 1844 grid cells
n_distinct(ewd_with_grid$grid_id)

ewd_in_hotspot <- st_join(ewd_with_grid, ea_hotspot)
ewd_in_hotspot |> 
  filter(!is.na(NAME)) |> 
  distinct(grid_id)
