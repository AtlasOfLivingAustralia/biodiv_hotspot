# This script describes how metadata pertaining to this project were derived

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
