# datasets added to sharepoint

# species list (richness)
fauna_df <- fauna |> 
  list_rbind(names_to = "taxon_type") 
flora_df <- flora |> 
  list_rbind(names_to = "taxon_type")
fauna_df |> 
  bind_rows(flora_df) |> 
  write_csv("output/species_list_20241223.csv")

# species list (endemism)
flora_endemic |> 
  map(~ .x |> 
        filter(endemic == "endemic")) |> 
  list_rbind(names_to = "taxon_type") |> 
  select(-c(scientific_name_authorship, taxon_rank, total_count, hotspot_count, prop_within_ibra, endemic)) |> 
  write_csv("output/endemic_species_list_flora_20241224.csv")

endm_files <- list.files(path = "data/interim-tables", full.names = TRUE)
endm_files |> 
  set_names(gsub(".*tables/([a-z]+)_.*", "\\1", endm_files)) |> 
  map(get_endemic_fauna) |> 
  list_rbind(names_to = "taxon_type") |> 
  write_csv("output/endemic_species_list_fauna_20241224.csv")

# summary table
flora_summary <- tibble(
  taxonomic_group = names(flora),
  species_richness = unlist(map(flora, nrow)),
  endemic_species = unlist(map(flora_endemic,
                               ~ nrow(filter(.x, endemic == "endemic")))))
fauna_richness <- tibble(
  taxonomic_group = names(fauna),
  species_richness = unlist(map(fauna, nrow)))

endm_fauna_counts |> 
  unlist() |> 
  data.frame() |> 
  rownames_to_column() |> 
  full_join(fauna_richness, by = join_by(rowname == taxonomic_group)) |> 
  select(taxonomic_group = rowname,
         species_richness, 
         endemic_species = unlist.endm_fauna_counts.) |> 
  bind_rows(flora_summary) |> 
  write_csv("output/summary_counts_20241224.csv")

# bioregional species list
readRDS(here("data", "processed", "species_list_bioregional.RDS")) |>
  distinct() |> 
  write_csv("output/species_list_bioregional_20241224.csv")
  