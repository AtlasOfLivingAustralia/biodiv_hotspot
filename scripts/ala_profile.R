# Gets the values for the ALA DQ profile, with descriptions and a list of the
# filters applied

search_profiles("ALA") |> 
  show_values() |>  
  select(description, filter) |> 
  write_csv(here("output", 
                 "ala_profile.csv"))
