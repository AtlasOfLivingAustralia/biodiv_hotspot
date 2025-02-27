get_n_species <- function(taxon, bioregions, ...) {
  
  galah_call() |> 
    identify(taxon) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950,
           cl1048 %in% bioregions, 
           countryConservation != "Extinct",
           countryConservation != "Extinct in the wild") |> 
    atlas_species()
  
}

reclassify_groups <- function(filename) {
  
  x <- readRDS(paste0("data/processed/", filename))
  x |> 
    list_rbind(names_to = "ala_classification") |>
    left_join(taxon_lookup, 
              by = "ala_classification", 
              relationship = "many-to-many") |>
    select(-c(type, ala_classification)) |>
    group_by(taxon_type) |> 
    distinct() %>% 
    split(f = as.factor(.$taxon_type))
  
}

get_aus_counts <- function(taxon_concept_id) {
  
  galah_call() |> 
    galah_apply_profile(ALA) |> 
    filter(taxonConceptID == taxon_concept_id,
           year >= 1950, 
           countryCode == "AU",
           !is.na(decimalLatitude), 
           !is.na(decimalLongitude)) |>
    atlas_counts()
  
}

get_region_counts <- function(taxon_concept_id, region_type) {
  
  galah_call() |> 
    galah_apply_profile(ALA) |> 
    filter(taxonConceptID == taxon_concept_id,
           year >= 1950,
           cl1048 %in% region_type,
           !is.na(decimalLatitude), 
           !is.na(decimalLongitude)) |>
    atlas_counts()
  
}

save_occ <- function(taxon_concept_id) {
  
  species_name <- pull(search_taxa(taxon_concept_id), species)
  
  galah_call() |> 
    galah_apply_profile(ALA) |> 
    filter(taxonConceptID == taxon_concept_id,
           year >= 1950, 
           countryCode == "AU",
           !is.na(decimalLatitude), 
           !is.na(decimalLongitude)) |> 
    select(species, 
           taxonConceptID,
           decimalLatitude, 
           decimalLongitude) |> 
    atlas_occurrences() |> 
    saveRDS(paste0("data/tmp_occ/", species_name, ".RDS"))
  
}

get_grid_counts <- function(fpath, region_sf) {
  
  occ <- readRDS(fpath)
  
  occ_sf <- occ |> 
    st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), 
             crs = 4326) |> 
    st_transform(crs = albers_crs)
  
  occ_in_grid <- st_join(occ_sf, aus_grid)
  total_count <- n_distinct(occ_in_grid$grid_id, na.rm = TRUE)
  
  occ_in_region <- st_join(occ_in_grid, region_sf)
  region_count <- occ_in_region |> 
    filter(!is.na(REG_NAME_7)) |> 
    distinct(grid_id) |> 
    filter(!is.na(grid_id)) |> 
    nrow()
  
  list(species_name = unique(occ$species), 
       taxon_concept_id = unique(occ$taxonConceptID),
       total_count = total_count,
       region_count = region_count)
  
}

get_endemic_spp <- function(filename) {
  
  grid_counts <- readRDS(paste0("data/processed/", filename))
  
  endemic_species <- grid_counts |> 
    left_join(vertebrate_taxa, by = "taxon_concept_id") |> 
    filter(!is.na(ala_classification)) |> 
    mutate(prop_within_region = round(region_count/total_count, 3),
           endemic = case_when(
             between(region_count, 10, 50) & prop_within_region == 1.00 ~ "endemic",
             region_count > 50 & prop_within_region >= 0.950 ~ "endemic")) |> 
    filter(endemic == "endemic") 
  
  x <- str_split_1(filename, pattern = "_")[1:2]
  y <- paste0(x[1], "_", x[2], "_")
  saveRDS(endemic_species, paste0("data/processed/", y, "endemic.RDS"))
  
}

get_putative_endemic_spp <- function(filename) {
  
  grid_counts <- readRDS(paste0("data/processed/", filename))
  
  putative_endemic_species <- grid_counts |> 
    left_join(vertebrate_taxa, by = "taxon_concept_id") |> 
    filter(!is.na(ala_classification)) |> 
    mutate(prop_within_region = round(region_count/total_count, 3),
           endemic = case_when(
             between(region_count, 10, 50) & prop_within_region == 1.00 ~ "endemic",
             region_count > 50 & prop_within_region >= 0.950 ~ "endemic")) |> 
    filter(is.na(endemic)) |>
    filter(between(region_count, 1, 9)) |> 
    select(taxon_concept_id, 
           species_name, 
           taxon_type = ala_classification,
           total_count,
           region_count)
  
  x <- str_split_1(filename, pattern = "_")[1:2]
  y <- paste0(x[1], "_", x[2], "_")
  write_csv(putative_endemic_species, paste0("output/", y, "possible_endemic.csv"))
  
}


summarise_counts <- function(spp_richness_csv, animal_endemic_csv, plant_endemic_csv, file_suffix) {
  
  spp_count <- read_csv(paste0("output/", spp_richness_csv)) |> 
    count(taxon_type, name = "species_richness")
  
  animals_endemic <- read_csv(paste0("output/", animal_endemic_csv)) |> 
    count(taxon_type, name = "endemic_species")
  
  plants_endemic <- read_csv(paste0("output/", plant_endemic_csv)) |> 
    count(taxon_type, name = "endemic_species")
  
  animals_endemic |> 
    bind_rows(plants_endemic) |> 
    full_join(spp_count, by = "taxon_type") |> 
    write_csv(paste0("output/summary_count_", file_suffix, ".csv"))
  
}
