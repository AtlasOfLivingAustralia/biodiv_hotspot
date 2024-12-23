birds <- get_n_species("aves")
tictoc::tic()
birds_endemic <- birds |> 
  mutate(count_all = unlist(pmap(.l = list(x = birds$taxon_concept_id),
                                 .f = function(x) {
                                   galah_call() |> 
                                     identify(x) |> 
                                     galah_apply_profile(ALA) |> 
                                     filter(year >= 1950, countryCode == "AU") |>
                                     atlas_counts()
                                 })),
         count_ibra = unlist(pmap(.l = list(x = birds$taxon_concept_id),
                                  .f = function(x) {
                                    galah_call() |> 
                                      identify(x) |> 
                                      galah_apply_profile(ALA) |> 
                                      filter(year >= 1950, 
                                             cl1048 %in% ibra) |>
                                      atlas_counts()
                                  })),
         #count_outside_ibra = count_all - count_ibra, 
         prop_within_ibra = round(count_ibra/count_all, 3),
         endemic_95 = case_when(
           between(count_ibra, 10, 50) & prop_within_ibra == 1.00 ~ "endemic",
           count_ibra > 50 & prop_within_ibra >= 0.950 ~ "endemic"),
         endemic_99 = case_when(
           between(count_ibra, 10, 50) & prop_within_ibra == 1.00 ~ "endemic",
           count_ibra > 50 & prop_within_ibra >= 0.990 ~ "endemic"))
tictoc::toc()



birds_occ <- galah_call() |> 
  identify("aves") |> 
  galah_apply_profile(ALA) |> 
  filter(year >= 1950, 
         countryCode == "AU",
         !is.na(decimalLatitude),
         !is.na(decimalLongitude)) |>
  select(species, decimalLongitude, decimalLatitude) |> 
  atlas_counts() 

amphib <- galah_call() |> 
  identify("amphibia") |> 
  galah_apply_profile(ALA) |> 
  filter(year >= 1950, countryCode == "AU") |> 
  select(species, decimalLongitude, decimalLatitude) |> 
  atlas_occurrences() |> 
  filter(species %in% frogs$species_name) 

