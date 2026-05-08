# This script counts the number of records for each taxon that are inside and
# outside the FEAH, and outputs a csv file with those numbers and the associated
# taxonomic ranks. These counts are to assist with the manual discrimination of
# taxa that are "truly" within the FEAH. Taxon concept IDs from previous data
# analyses are invalid since the latest taxonomy update, so species names are
# run against name matching service first, before getting counts. Reference
# lists are from Kristen Williams.

#### vertebrates -------
verts_ref_list <- read_xlsx(here("data", "FEAH vertebrate species richness - master list v3.xlsx"))

verts_new_tcids <- search_taxa(verts_ref_list$species_name)

# do each region manually because it's easier to troubleshoot for issues, 
# although better form to wrap this whole section up in a function
# hotspot
verts_hotspot_counts <- verts_new_tcids$taxon_concept_id |> 
  map(get_in_out_counts, region = hotspot_regions) |> 
  list_rbind()
  
full_join(verts_hotspot_counts, verts_new_tcids, by = "taxon_concept_id") |> 
  select(inside, outside, search_term) |> 
  full_join(verts_ref_list, by = join_by(search_term == species_name)) |> 
  write_csv(here("output", "vertebrates_inside_outside_hotspot.csv"))

#tropics
verts_tropics_counts <- verts_new_tcids$taxon_concept_id |> 
  map(get_in_out_counts, region = tropics_regions) |> 
  list_rbind()

full_join(verts_tropics_counts, verts_new_tcids, by = "taxon_concept_id") |> 
  select(inside, outside, search_term) |> 
  full_join(verts_ref_list, by = join_by(search_term == species_name)) |> 
  write_csv(here("output", "vertebrates_inside_outside_tropics.csv"))

# temperate
verts_temperate_counts <- verts_new_tcids$taxon_concept_id |> 
  map(get_in_out_counts, region = temperate_regions) |> 
  list_rbind()

full_join(verts_temperate_counts, verts_new_tcids, by = "taxon_concept_id") |> 
  select(inside, outside, search_term) |> 
  full_join(verts_ref_list, by = join_by(search_term == species_name)) |> 
  write_csv(here("output", "vertebrates_inside_outside_temperate.csv"))


#### plants ------------
plants_ref_list <- read_csv(here("data", "VascularPlants_exIDs_for_Shandiya.csv"))

plants_new_tcids <- search_taxa(plants_ref_list$species_name)

# anything that doesn't match to at least rank will have to be manually checked 
plants_new_tcids |> 
  filter(!rank %in% c("species", "subspecies", "variety")) |> 
  write_csv("plants_unmatched_20260302.csv")

plants_matched_tcids <- plants_new_tcids |> 
  filter(rank %in% c("species", "subspecies", "variety")) |> 
  pull(taxon_concept_id) 

# keep getting server-side errors so download occurrences and summarise instead
plants_occ <- galah_call() |>
  filter(class == "Equisetopsida",
         year >= 1950) |> 
  apply_profile(ALA) |>
  select(order, family, genus, species, taxonConceptID, cl1048) |> 
  atlas_occurrences()

arrow::write_parquet(plants_occ, here("data", "plants_occ.parquet"))

# within hotspots
plants_inside_hotspot <- plants_occ |> 
  filter(cl1048 %in% hotspot_regions) |> 
  count(taxonConceptID) |> 
  full_join(plants_new_tcids, by = join_by(taxonConceptID == taxon_concept_id)) |> 
  filter(!is.na(search_term)) |> 
  rename(inside = n) |> 
  filter(!is.na(taxonConceptID)) |> 
  mutate(inside = replace_na(inside, 0)) |> 
  select(inside, search_term, taxonConceptID, scientific_name_authorship, 
         kingdom, phylum, class, order, family, genus, vernacular_name)

plants_outside_hotspot <- plants_occ |> 
  filter(!cl1048 %in% hotspot_regions) |> 
  count(taxonConceptID) |> 
  full_join(plants_new_tcids, by = join_by(taxonConceptID == taxon_concept_id)) |> 
  filter(!is.na(search_term)) |> 
  rename(outside = n) |> 
  filter(!is.na(taxonConceptID)) |> 
  mutate(outside = replace_na(outside, 0)) |> 
  select(outside, search_term, taxonConceptID, scientific_name_authorship, 
         kingdom, phylum, class, order, family, genus, vernacular_name)

plants_inside_hotspot |> 
  full_join(plants_outside_hotspot, by = join_by(taxonConceptID, 
                                                 search_term, 
                                                 kingdom, 
                                                 phylum, 
                                                 class, 
                                                 order,
                                                 family, 
                                                 genus, 
                                                 scientific_name_authorship, 
                                                 vernacular_name)) |> 
  relocate(outside, .after = inside) |> 
  write_csv(here("output", "plants_inside_outside_hotspot.csv"))

# tropics
plants_inside_tropics <- plants_occ |> 
  filter(cl1048 %in% tropics_regions) |> 
  count(taxonConceptID) |> 
  full_join(plants_new_tcids, by = join_by(taxonConceptID == taxon_concept_id)) |> 
  filter(!is.na(search_term)) |> 
  rename(inside = n) |> 
  filter(!is.na(taxonConceptID)) |> 
  mutate(inside = replace_na(inside, 0)) |> 
  select(inside, search_term, taxonConceptID, scientific_name_authorship, 
         kingdom, phylum, class, order, family, genus, vernacular_name)

plants_outside_tropics <- plants_occ |> 
  filter(!cl1048 %in% tropics_regions) |> 
  count(taxonConceptID) |> 
  full_join(plants_new_tcids, by = join_by(taxonConceptID == taxon_concept_id)) |> 
  filter(!is.na(search_term)) |> 
  rename(outside = n) |> 
  filter(!is.na(taxonConceptID)) |> 
  mutate(outside = replace_na(outside, 0)) |> 
  select(outside, search_term, taxonConceptID, scientific_name_authorship, 
         kingdom, phylum, class, order, family, genus, vernacular_name)

plants_inside_tropics |> 
  full_join(plants_outside_tropics, by = join_by(taxonConceptID, 
                                                 search_term, 
                                                 kingdom, 
                                                 phylum, 
                                                 class, 
                                                 order,
                                                 family, 
                                                 genus, 
                                                 scientific_name_authorship, 
                                                 vernacular_name)) |> 
  relocate(outside, .after = inside) |> 
  write_csv(here("output", "plants_inside_outside_tropics.csv"))

# temperate
plants_inside_temperate <- plants_occ |> 
  filter(cl1048 %in% temperate_regions) |> 
  count(taxonConceptID) |> 
  full_join(plants_new_tcids, by = join_by(taxonConceptID == taxon_concept_id)) |> 
  filter(!is.na(search_term)) |> 
  rename(inside = n) |> 
  filter(!is.na(taxonConceptID)) |> 
  mutate(inside = replace_na(inside, 0)) |> 
  select(inside, search_term, taxonConceptID, scientific_name_authorship, 
         kingdom, phylum, class, order, family, genus, vernacular_name)

plants_outside_temperate <- plants_occ |> 
  filter(!cl1048 %in% temperate_regions) |> 
  count(taxonConceptID) |> 
  full_join(plants_new_tcids, by = join_by(taxonConceptID == taxon_concept_id)) |> 
  filter(!is.na(search_term)) |> 
  rename(outside = n) |> 
  filter(!is.na(taxonConceptID)) |> 
  mutate(outside = replace_na(outside, 0)) |> 
  select(outside, search_term, taxonConceptID, scientific_name_authorship, 
         kingdom, phylum, class, order, family, genus, vernacular_name)

plants_inside_temperate |> 
  full_join(plants_outside_temperate, by = join_by(taxonConceptID, 
                                                 search_term, 
                                                 kingdom, 
                                                 phylum, 
                                                 class, 
                                                 order,
                                                 family, 
                                                 genus, 
                                                 scientific_name_authorship, 
                                                 vernacular_name)) |> 
  relocate(outside, .after = inside) |> 
  write_csv(here("output", "plants_inside_outside_temperate.csv"))


#### fish -------
fish_ref_list <- read_xlsx(here("data", "Freshwater_fish_tocheck_v2.xlsx"))

fish_new_tcids <- search_taxa(fish_ref_list$species_name)

# hotspot
fish_hotspot_counts <- fish_new_tcids |> 
  filter(rank != "genus") |> 
  pull(taxon_concept_id) |> 
  map(get_in_out_counts, region = hotspot_regions) |> 
  list_rbind()

full_join(fish_hotspot_counts, fish_new_tcids, by = "taxon_concept_id") |> 
  distinct() |>  
  select(inside, outside, search_term, taxon_concept_id) |>
  # because provided list is missing a lot of taxon concept IDs
  rename(taxon_concept_id_updated = taxon_concept_id) |> 
  full_join(fish_ref_list, by = join_by(search_term == species_name)) |>
  write_csv(here("output", "fish_inside_outside_hotspot.csv"))

# tropics
fish_tropics_counts <- fish_new_tcids |> 
  filter(rank != "genus") |> 
  pull(taxon_concept_id) |> 
  map(get_in_out_counts, region = tropics_regions) |> 
  list_rbind()

full_join(fish_tropics_counts, fish_new_tcids, by = "taxon_concept_id") |> 
  distinct() |>  
  select(inside, outside, search_term, taxon_concept_id) |>
  rename(taxon_concept_id_updated = taxon_concept_id) |> 
  full_join(fish_ref_list, by = join_by(search_term == species_name)) |> 
  write_csv(here("output", "fish_inside_outside_tropics.csv"))

# temperate
fish_temperate_counts <- fish_new_tcids |> 
  filter(rank != "genus") |> 
  pull(taxon_concept_id) |> 
  map(get_in_out_counts, region = temperate_regions) |> 
  list_rbind()

full_join(fish_temperate_counts, fish_new_tcids, by = "taxon_concept_id") |> 
  distinct() |>  
  select(inside, outside, search_term, taxon_concept_id) |>
  rename(taxon_concept_id_updated = taxon_concept_id) |> 
  full_join(fish_ref_list, by = join_by(search_term == species_name)) |> 
  write_csv(here("output", "fish_inside_outside_temperate.csv"))
