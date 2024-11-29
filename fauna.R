

fauna <- c("aves",
           "mammalia",
           "reptilia",
           "amphibia",
           "agnatha",
           "actinopterygii",
           "chondrichthyes",
           "sarcopterygii") |> 
  set_names() |> 
  map(get_n_species)

# takes 2016.58 sec to run
fauna_endemic <- fauna |> 
  map(~ .x |> 
        mutate(
          count_all = unlist(pmap(list(.x$taxon_concept_id), get_all_counts)),
          count_ibra = unlist(pmap(list(.x$taxon_concept_id), get_ibra_counts)),
          count_outside_ibra = count_all - count_ibra,
          prop_within_ibra = round(count_ibra/count_all, 2),
          endemic = case_when(
            between(count_ibra, 10, 50) & prop_within_ibra == 1.00 ~ "endemic",
            count_ibra > 50 & prop_within_ibra >= 0.95 ~ "endemic")))

saveRDS(fauna_endemic, "fauna_endemic.RDS")



tibble(taxonomic_group = names(test),
       species = unlist(map(test, nrow)),
       endemic_species = unlist(map(test_endemic,
                             ~nrow(filter(.x, endemic == "endemic")))),
       # mutate this later
       percent_endemism = c(),
       endemic_genera = c(),
       endemic_families = c())





put_end_gen <- map(test_endemic, ~ tabyl(.x, genus, endemic))
          
tibble(tax_grp = names(bird_test),
       species = unlist(map(bird_test, nrow)),
       end_spp_count = unlist(map(test_endemic,
                                  ~ nrow(filter(.x, endemic == "endemic")))),
       end_gen_count = unlist(map(test_endemic,
                                  ~ .x |> 
                                    tabyl(genus, endemic) |> 
                                    filter(NA_ == 0) |> 
                                    nrow())),
       end_fam_count = unlist(map(test_endemic,
                                  ~ .x |> 
                                    tabyl(family, endemic) |> 
                                    filter(NA_ == 0) |> 
                                    nrow()))
       )
