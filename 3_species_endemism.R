# Calculations of species endemism for vascular plants and vertebrate species.
# For plants, endemism is calculated based on the proportion of occurrence
# records occurring within the hotspot relative to the total number of
# occurrences across Australia. 
# For animals, occurrences are first generalised to a 10 by 10 km grid and
# endemism is calculated as a proportion of occupied grid cells rather than a
# proportion of records (mitigates somewhat issues around sampling inconsistency)


# vascular plants ------
flora_endemic <- flora |>
  map(~ .x |>
        mutate(
          total_count = unlist(pmap(list(.x$taxon_concept_id), get_all_counts)),
          hotspot_count = unlist(pmap(list(.x$taxon_concept_id), get_ibra_counts)),
          prop_within_ibra = round(hotspot_count/total_count, 3),
          endemic = case_when(
            between(hotspot_count, 10, 50) & prop_within_ibra == 1.00 ~ "endemic",
            hotspot_count > 50 & prop_within_ibra >= 0.950 ~ "endemic")))


saveRDS(flora_endemic, here("data", "processed", "flora_endemic.RDS"))


# vertebrates -----------

# spatial wrangling :
# projections are to Australian Albers Equal-Area CRS 3577
albers_crs = 3577
grid_size = 10000

# grid across terrestrial aus
aus_map <- st_transform(ozmap_country, crs = albers_crs)

aus_grid <- st_make_grid(aus_map, 
                         cellsize = c(grid_size, grid_size),
                         square = TRUE) |> 
  st_intersection(st_geometry(aus_map)) |>  
  st_as_sf() |> 
  st_set_geometry("grid_geometry") |> 
  tibble::rowid_to_column(var = "grid_id")

# hotspot boundary  
hotspot_sf <- st_read(here("data", 
                           "spatial", 
                           "hotspots_2016_1", 
                           "hotspots_2016_1.shp")) |>
  filter(NAME == "Forests of East Australia") |>
  st_transform(crs = 3577)

# grid counts 
# there is almost definitely a better way to do this but it currently eludes me
fauna[["reptiles"]]$taxon_concept_id |> 
  map(get_grid_counts) |> 
  bind_rows() |> 
  saveRDS("reptiles_endemic.RDS")

fauna[["birds"]]$taxon_concept_id |> 
  map(get_grid_counts) |> 
  bind_rows() |> 
  saveRDS("birds_endemic.RDS")

fauna[["mammals"]]$taxon_concept_id |> 
  map(get_grid_counts) |> 
  bind_rows() |> 
  saveRDS("mammals_endemic.RDS")

fauna[["amphibians"]]$taxon_concept_id |> 
  map(get_grid_counts) |> 
  bind_rows() |> 
  saveRDS("amphibians_endemic.RDS")

fauna[["fish"]]$taxon_concept_id |> 
  map(get_grid_counts) |> 
  bind_rows() |> 
  saveRDS("fish_endemic.RDS")

# get counts of endemism
# NOTE: Threshold for birds is 87% based on eyeballing species lists. Threshold
# for everything else is 95%, following methods in previous chapter. This means
# numbers for birds are potentially more accurate than those for other taxa
endm_files <- list.files(path = "data/interim-tables", full.names = TRUE)
endm_fauna_counts <- endm_files |> 
  set_names(gsub(".*tables/([a-z]+)_.*", "\\1", endm_files)) |> 
  map(calc_endm)

endm_files |> 
  set_names(gsub(".*tables/([a-z]+)_.*", "\\1", endm_files)) |> 
  map(get_endemic_fauna)  
  



