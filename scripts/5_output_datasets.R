# This script modifies the processed files generated in 2_species_richness.R and
# 4_species_endemism.R to create output files added to the SharePoint folder

# species richness -----
### hotspot ------
plants <- reclassify_groups("vascular_plants_hotspot.RDS")
animals <- reclassify_groups("vertebrates_hotspot.RDS")

plants_df <- plants |> 
  list_rbind(names_to = "taxon_type") |> 
  filter(taxon_rank == "species") |> 
  select(-species, -taxon_rank) 
animals_df <- animals |> 
  list_rbind(names_to = "taxon_type") |> 
  select(-taxon_rank)

animals_df |> 
  bind_rows(plants_df) |>
  write_csv(here("output", "species_richness_hotspot.csv"))

### ecoregions: tropics ------
plants_tropics <- reclassify_groups("vascular_plants_tropics.RDS")
animals_tropics <- reclassify_groups("vertebrates_tropics.RDS")

plants_tropics_df <- plants_tropics |> 
  list_rbind(names_to = "taxon_type") |> 
  filter(taxon_rank == "species") |> 
  select(-species, -taxon_rank) 
animals_tropics_df <- animals_tropics |> 
  list_rbind(names_to = "taxon_type") |> 
  select(-species, -taxon_rank)

animals_tropics_df |> 
  bind_rows(plants_tropics_df) |> 
  write_csv(here("output", "species_richness_tropics.csv"))

### ecoregions: temperate --------
plants_temperate <- reclassify_groups("vascular_plants_temperate.RDS")
animals_temperate <- reclassify_groups("vertebrates_temperate.RDS")

plants_temperate_df <- plants_temperate |> 
  list_rbind(names_to = "taxon_type") |>
  filter(taxon_rank == "species") |> 
  select(-species, -taxon_rank) 
animals_temperate_df <- animals_temperate |> 
  list_rbind(names_to = "taxon_type") |> 
  select(-taxon_rank)

animals_temperate_df |> 
  bind_rows(plants_temperate_df) |> 
  write_csv(here("output", "species_richness_temperate.csv"))


# species endemism: vascular plants ----------
### hotspot -------
readRDS(here("data", "processed", "vascular_plants_hotspot_endemic.RDS")) |> 
  list_rbind(names_to = "taxon_type") |> 
  filter(taxon_rank == "species", 
         endemic == "endemic") |> 
  select(taxon_concept_id, species_name, taxon_type) |> 
  write_csv(here("output", "vascular_plants_hotspot_endemic.csv"))

### ecoregions: tropics ------
readRDS(here("data", "processed", "vascular_plants_tropics_endemic.RDS")) |> 
  list_rbind(names_to = "taxon_type") |> 
  filter(taxon_rank == "species", 
         endemic == "endemic") |> 
  select(taxon_concept_id, species_name, taxon_type) |> 
  write_csv(here("output", "vascular_plants_tropics_endemic.csv"))

### ecoregions: temperate --------
readRDS(here("data", "processed", "vascular_plants_temperate_endemic.RDS")) |> 
  list_rbind(names_to = "taxon_type") |> 
  filter(taxon_rank == "species", 
         endemic == "endemic") |> 
  select(taxon_concept_id, species_name, taxon_type) |> 
  write_csv(here("output", "vascular_plants_temperate_endemic.csv"))


# species endemism: vertebrates ----------
### hotspot -------
readRDS(here("data", "processed", "vertebrates_hotspot_endemic.RDS")) |> 
  select(taxon_concept_id, species_name, taxon_type = ala_classification) |> 
  write_csv(here("output", "vertebrates_hotspot_endemic.csv"))

### ecoregions: tropics ------
readRDS(here("data", "processed", "vertebrates_tropics_endemic.RDS")) |> 
  select(taxon_concept_id, species_name, taxon_type = ala_classification) |> 
  write_csv(here("output", "vertebrates_tropics_endemic.csv"))

### ecoregions: temperate --------
readRDS(here("data", "processed", "vertebrates_temperate_endemic.RDS")) |> 
  select(taxon_concept_id, species_name, taxon_type = ala_classification) |> 
  write_csv(here("output", "vertebrates_temperate_endemic.csv"))


# summary counts ------
### hotspot -------
summarise_counts(spp_richness_csv = "species_richness_hotspot.csv",
                 animal_endemic_csv = "vertebrates_hotspot_endemic.csv",
                 plant_endemic_csv = "vascular_plants_hotspot_endemic.csv", 
                 file_suffix = "hotspot")

### ecoregions: tropics ------
summarise_counts(spp_richness_csv = "species_richness_tropics.csv",
                 animal_endemic_csv = "vertebrates_tropics_endemic.csv",
                 plant_endemic_csv = "vascular_plants_tropics_endemic.csv", 
                 file_suffix = "tropics")

### ecoregions: temperate --------
summarise_counts(spp_richness_csv = "species_richness_temperate.csv",
                 animal_endemic_csv = "vertebrates_temperate_endemic.csv",
                 plant_endemic_csv = "vascular_plants_temperate_endemic.csv", 
                 file_suffix = "temperate")
