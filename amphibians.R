# this is the value for the first cell: number of unique species
# 171 species
frogs <- galah_call() |> 
  identify("amphibia") |> 
  galah_apply_profile(ALA) |> 
  filter(year >= 1950,
         cl1048 %in% ibra) |> 
  atlas_species()

# 85 endemic species
# galah_call() |> 
#   identify(frogs$taxon_concept_id[1]) |> 
#   galah_apply_profile(ALA) |> 
#   filter(year >= 1950, 
#          cl1048 %in% ibra_14) |>
#   atlas_counts()
  
# 79.469 sec elapsed - takes about half a second per taxon
frog_count <- frogs |> 
  mutate(count_all = unlist(pmap(.l = list(x = frogs$taxon_concept_id),
                                 .f = function(x) {
                                   galah_call() |> 
                                     identify(x) |> 
                                     galah_apply_profile(ALA) |> 
                                     filter(year >= 1950) |>
                                     atlas_counts()
                                 })),
         count_ibra = unlist(pmap(.l = list(x = frogs$taxon_concept_id),
                           .f = function(x) {
                             galah_call() |> 
                               identify(x) |> 
                               galah_apply_profile(ALA) |> 
                               filter(year >= 1950, 
                                      cl1048 %in% ibra) |>
                               atlas_counts()
                           })),
         count_outside_ibra = count_all - count_ibra, 
         prop_within_ibra = round(count_ibra/count_all, 2),
         endemic = case_when(
           between(count_ibra, 10, 50) & prop_within_ibra == 1.00 ~ "endemic",
           count_ibra > 50 & prop_within_ibra >= 0.95 ~ "endemic"))

endemic_spp_count <- frog_count |> 
  filter(endemic == "endemic") |> 
  nrow() 

# get a list of putative endemic genera by removing any with > 0 non-endemic
# species i.e. with > 0 in the NA column of frog_endemic 
# this reduces time spent searching using galah for larger taxonomic groups, but
# it would also work if you didn't care about this and skipped the initial
# filtering step, and just put all the genera through the atlas_species() chunk
# of code

putative_endemic_genera <- frog_count |>
  tabyl(genus, endemic) |>
  filter(NA_ == 0) 

# run the next steps if nrow(putative endemic genera) > 0
n_species_overall <- galah_call() |> 
  identify(pull(putative_endemic_genera, genus)) |> 
  galah_apply_profile(ALA) |>
  filter(year >= 1950) |>
  atlas_species() |> 
  count(genus)

endemic_genera_count <- n_species_overall |> 
  full_join(putative_endemic_genera, by = join_by(genus)) |> 
  filter(`n` == endemic) |> 
  nrow()

# endemic families
endemic_family_count <- frog_count |> 
  tabyl(family, endemic) |> 
  filter(NA_ == 0) |> 
  nrow()

amphibians <- tibble(taxonomic_group = "Amphibians",
                     species = nrow(frogs),
                     endemic_species = endemic_spp_count,
                     percent_endemism = round(endemic_spp_count/nrow(frogs), 3),
                     endemic_genera = endemic_genera_count,
                     endemic_families = endemic_family_count)
