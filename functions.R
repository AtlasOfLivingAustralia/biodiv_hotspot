get_n_species <- function(taxon) {
  
  galah_call() |> 
    identify(taxon) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950,
           cl1048 %in% ibra, 
           countryConservation != "Extinct",
           countryConservation != "Extinct in the wild") |> 
    atlas_species()
  
}

get_n_species_ibra <- function(taxon, ibra_region) {
  
  galah_call() |> 
    identify(taxon) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950,
           cl1048 == ibra_region, 
           countryConservation != "Extinct",
           countryConservation != "Extinct in the wild") |> 
    atlas_species()
  
}

get_all_counts <- function(taxonID) {
  
  galah_call() |> 
    identify(taxonID) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950, 
           countryCode == "AU",
           !is.na(decimalLatitude), 
           !is.na(decimalLongitude)) |>
    atlas_counts()
  
}

get_ibra_counts <- function(taxonID) {
  
  galah_call() |> 
    identify(taxonID) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950,
           cl1048 %in% ibra,
           !is.na(decimalLatitude), 
           !is.na(decimalLongitude)) |>
    atlas_counts()
  
}

get_grid_counts <- function(taxon_concept_id) {
  
  species_name <- pull(search_taxa(taxon_concept_id), species)
  
  occ_sf <- galah_call() |> 
    identify(taxon_concept_id) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950, 
           countryCode == "AU",
           !is.na(decimalLatitude), 
           !is.na(decimalLongitude)) |> 
    select(species, 
           decimalLatitude, 
           decimalLongitude) |> 
    atlas_occurrences() |> 
    st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326) |> 
    st_transform(crs = albers_crs)
  
  occ_in_grid <- st_join(occ_sf, aus_grid)
  total_count <- n_distinct(occ_in_grid$grid_id)
  
  occ_in_hotspot <- st_join(occ_in_grid, hotspot_sf)
  hotspot_count <- occ_in_hotspot |> 
    filter(!is.na(NAME)) |> 
    distinct(grid_id) |> 
    nrow()
  
  list(species_name = species_name, 
       taxon_concept_id = taxon_concept_id,
       total_count = total_count,
       hotspot_count = hotspot_count)
  
}

calc_endm <- function(fpath) {
  
  if(grepl("birds", fpath)) {
    x <- readRDS(fpath) |> 
      mutate(prop = round(hotspot_count/total_count, 3),
             endm = case_when(
               between(hotspot_count, 10, 50) & prop == 1.00 ~ "endemic",
               hotspot_count > 50 & prop >= 0.870 ~ "endemic"))
  } else {
    x <- readRDS(fpath) |> 
      mutate(prop = round(hotspot_count/total_count, 3),
             endm = case_when(
               between(hotspot_count, 10, 50) & prop == 1.00 ~ "endemic",
               hotspot_count > 50 & prop >= 0.950 ~ "endemic"))
  }
  
  x |> 
    filter(endm == "endemic") |> 
    nrow()
  
}
