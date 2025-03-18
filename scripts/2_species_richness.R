# This script generates species lists for vertebrates and vascular plants
# occurring within the hotspot or each of the two ecoregions. Species on the
# lists match the ALA general data quality profile, have records from 1950
# onwards, are not listed as extinct or extinct in the wild by the EPBC, do not
# occur on the GRIIS or non-native species lists, and are not hybrids (where 
# the species name follows the patterns: string x string OR string X string).

# vertebrates ------
# hotspot 
taxon_lookup |>
  filter(type == "vertebrates") |>
  pull(ala_classification) |>
  set_names() |>
  map(get_n_species, bioregions = hotspot_regions) |> 
  map(\(df)
      df |> 
        filter(!species_name %in% griis_list_matched$scientific_name, 
               !str_detect(species_name, "(?i)^.+\\s+x\\s+.+$")) |> 
        anti_join(nnsl, by = join_by(species_name == scientific_name, family, kingdom))) |> 
  saveRDS(here("data", "processed", "vertebrates_hotspot.RDS"))

# ecoregions 
taxon_lookup |>
  filter(type == "vertebrates") |>
  pull(ala_classification) |>
  set_names() |>
  map(get_n_species, bioregions = tropics_regions) |> 
  map(\(df)
      df |>
        # sarcopterygii is empty, and atlas_species() has a bug that results in
        # unformatted column names
        clean_names() |> 
        filter(!species_name %in% griis_list_matched$scientific_name, 
               !str_detect(species_name, "(?i)^.+\\s+x\\s+.+$")) |> 
        anti_join(nnsl, by = join_by(species_name == scientific_name, family, kingdom))) |>
  saveRDS(here("data", "processed", "vertebrates_tropics.RDS"))

taxon_lookup |>
  filter(type == "vertebrates") |>
  pull(ala_classification) |>
  set_names() |>
  map(get_n_species, bioregions = temperate_regions) |> 
  map(\(df)
      df |>
        filter(!species_name %in% griis_list_matched$scientific_name, 
               !str_detect(species_name, "(?i)^.+\\s+x\\s+.+$")) |> 
        anti_join(nnsl, by = join_by(species_name == scientific_name, family, kingdom))) |>
  saveRDS(here("data", "processed", "vertebrates_temperate.RDS"))


# vascular plants --------
# hotspot
taxon_lookup |> 
  filter(type == "vascular plants") |> 
  pull(ala_classification) |>
  set_names() |> 
  map(get_n_species, bioregions = hotspot_regions) |> 
  map(\(df)
      df |>
        clean_names() |> 
        filter(!species_name %in% griis_list_matched$scientific_name, 
               !str_detect(species_name, "(?i)^.+\\s+x\\s+.+$")) |> 
        anti_join(nnsl, by = join_by(species_name == scientific_name, family, kingdom))) |>
  saveRDS(here("data", "processed", "vascular_plants_hotspot.RDS"))

# ecoregions
taxon_lookup |>
  filter(type == "vascular plants") |>
  pull(ala_classification) |>
  set_names() |>
  map(get_n_species, bioregions = tropics_regions) |> 
  map(\(df)
      df |>
        clean_names() |> 
        filter(!species_name %in% griis_list_matched$scientific_name, 
               !str_detect(species_name, "(?i)^.+\\s+x\\s+.+$")) |> 
        anti_join(nnsl, by = join_by(species_name == scientific_name, family, kingdom))) |>
  saveRDS(here("data", "processed", "vascular_plants_tropics.RDS"))

taxon_lookup |>
  filter(type == "vascular plants") |>
  pull(ala_classification) |>
  set_names() |>
  map(get_n_species, bioregions = temperate_regions) |> 
  map(\(df)
      df |>
        clean_names() |> 
        filter(!species_name %in% griis_list_matched$scientific_name, 
               !str_detect(species_name, "(?i)^.+\\s+x\\s+.+$")) |> 
        anti_join(nnsl, by = join_by(species_name == scientific_name, family, kingdom))) |>
  saveRDS(here("data", "processed", "vascular_plants_temperate.RDS"))
