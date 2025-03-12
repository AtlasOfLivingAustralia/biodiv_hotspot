# This script derives metedata relating to this project 

# 1. ALA DQ profile -------
# Gets the values for the ALA DQ profile, with descriptions and a list of the
# filters applied

search_profiles("ALA") |> 
  show_values() |>  
  select(description, filter) |> 
  write_csv(here("output", 
                 "ala_profile.csv"))


# 2. Taxonomic records -------- 
# The taxonomic groups used in the summary table, and the corresponding
# taxonomic groups in the ALA that went into taxonomic filtering

read_csv("data/taxon_lookup.csv") |> 
  write_csv("output/taxon_reference.csv")


# 3. Data sources ---------
# Names of data providers within the ALA that contributed data used in these
# analyses, and the counts of records from each data provider that were
# initially downloaded

galah_call() |> 
  identify(taxon_lookup$ala_classification) |> 
  galah_apply_profile(ALA) |> 
  filter(year >= 1950,
         cl1048 %in% hotspot_regions, 
         countryConservation != "Extinct",
         countryConservation != "Extinct in the wild") |> 
  group_by(dataResourceName) |>
  atlas_counts() |> 
  write_csv("output/data_sources_biodiv_hotspot.csv")

# 4. Fish habitats ------
readRDS("data/processed/fish_habitats.RDS") |> 
  write_csv("output/fish_habitats.csv")
