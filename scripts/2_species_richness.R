# This script gets a list of species occurring within the hotspot, delineated by
# 14 IBRA regions
# These numbers correspond to species richness for each taxa in the region

ibra <- readRDS(here("data", "spatial", "ibra_hotspot.RDS")) |> 
  pull(REG_NAME_7)

taxon_lookup <- read_csv(here("data", "taxon_lookup.csv"))

# vertebrates ----
vertebrates <- taxon_lookup |> 
  filter(type == "vertebrates") |> 
  pull(ala_classification) |> 
  set_names() |> 
  map(get_n_species)

fauna <- list(birds = vertebrates$aves, 
              mammals = vertebrates$mammalia, 
              reptiles = vertebrates$reptilia, 
              amphibians = vertebrates$amphibia, 
              fish = bind_rows(vertebrates$agnatha, 
                               vertebrates$actinopterygii, 
                               vertebrates$chondrichthyes, 
                               vertebrates$sarcopterygii))

saveRDS(fauna, here("data", "processed", "fauna.RDS"))

# vascular plants ------
monocots <- taxon_lookup |> 
  filter(taxon_type == "monocots") |> 
  pull(ala_classification) |>
  get_n_species()
  
dicots <- taxon_lookup |> 
  filter(taxon_type == "dicots") |> 
  pull(ala_classification) |>
  get_n_species()

gymnosperms <- taxon_lookup |> 
  filter(taxon_type == "gymnosperms") |> 
  pull(ala_classification) |>
  get_n_species()
  
ferns <- taxon_lookup |> 
  filter(taxon_type == "ferns") |> 
  pull(ala_classification) |>
  get_n_species()
  
flora <- list(dicots = dicots, 
              monocots = monocots, 
              ferns = ferns, 
              gymnosperms = gymnosperms)

saveRDS(flora, here("data", "processed", "flora.RDS"))

# bioregional analyses ---------
expanded_taxa_ibra <- expand.grid(taxon_names = taxon_lookup$ala_classification,
                                  ibra_names = ibra)

map2(expanded_taxa_ibra$taxon_names, expanded_taxa_ibra$ibra_names, get_n_species_ibra) |> 
  set_names(paste0(expanded_taxa_ibra$taxon_names, "_", expanded_taxa_ibra$ibra_names)) |> 
  list_rbind(names_to = "taxa_ibra") |> 
  remove_empty(which = c("cols")) |> 
  select(-scientific_name_authorship, -taxon_rank) |> 
  separate_wider_delim(taxa_ibra, delim = "_", names = c("ala_classification", "ibra")) |> 
  left_join(taxon_lookup, by = "ala_classification") |> 
  select(-ala_classification) |> 
  saveRDS(here("data", "processed", "species_list_bioregional.RDS"))
