# This script gets a list of species occurring within the hotspot, delineated by
# 14 IBRA regions
# These numbers correspond to species richness for each taxa in the region

ibra <- readRDS(here("data", "spatial", "ibra_hotspot.RDS")) |> 
  pull(REG_NAME_7)

# vertebrates ----
vertebrates <- c("aves",
                 "mammalia",
                 "reptilia",
                 "amphibia",
                 "agnatha",
                 "actinopterygii",
                 "chondrichthyes",
                 "sarcopterygii") |> 
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
monocots <- get_n_species(c("Bromaceae", 
                            "Cypripediaceae", 
                            "Melanthiaceae", 
                            "Lilianae")) 

dicots <- get_n_species(c("Magnoliidae", "Desfontainiaceae", "Bruniaceae",
                          "Buxaceae", "Chloranthaceae", "Staphyleaceae",
                          "Strasburgeriaceae", "Dipentodontaceae", "Tapisciaceae",
                          "Picramniaceae", "Canellaceae", "Chloanthaceae",
                          "Cornaceae", "Cynomoriaceae", "Cyrillaceae", 
                          "Garryaceae", "Magnoliaceae", "Nesogenaceae",
                          "Saururaceae", "Styracaceae", "Trapaceae"))

gymnosperms <- get_n_species(c("Pinidae", 
                               "Pinophyta", 
                               "Spermatophytina", 
                               "Ephedraceae Dumort."))

ferns <- get_n_species(c("Polypodiidae",
                         "Marattiaceae",
                         "Ophioglossaceae",
                         "Psilotaceae",
                         "Polypodiopsida",
                         "Hymenophyllaceae",
                         "Psilotaceae",
                         "Pteridaceae",
                         "Salviniaceae",
                         "Pteridophyta"))

flora <- list(dicots = dicots, 
              monocots = monocots, 
              ferns = ferns, 
              gymnosperms = gymnosperms)

saveRDS(flora, here("data", "processed", "flora.RDS"))

# bioregional analyses ---------
vert_names <- c("aves",
                "mammalia",
                "reptilia",
                "amphibia",
                "agnatha",
                "actinopterygii",
                "chondrichthyes",
                "sarcopterygii")

expanded_vert_ibra <- expand.grid(taxon_names = vert_names, ibra_names = ibra)

map2(expanded_vert_ibra$taxon_names, 
     expanded_vert_ibra$ibra_names, 
     get_n_species_ibra) |> 
  set_names(paste0(expanded_vert_ibra$taxon_names, "_", expanded_vert_ibra$ibra_names)) |> 
  saveRDS(here("data", "processed", "fauna_bioregional.RDS"))


