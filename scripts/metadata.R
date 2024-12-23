# This script desribes how metadata pertaining to this project were derived

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

fish <- c("agnatha",
          "actinopterygii",
          "chondrichthyes",
          "sarcopterygii")

monocots <- c("Bromaceae", 
              "Cypripediaceae", 
              "Melanthiaceae", 
              "Lilianae")

dicots <- c("Magnoliidae", "Desfontainiaceae", "Bruniaceae",
            "Buxaceae", "Chloranthaceae", "Staphyleaceae",
            "Strasburgeriaceae", "Dipentodontaceae", "Tapisciaceae",
            "Picramniaceae", "Canellaceae", "Chloanthaceae",
            "Cornaceae", "Cynomoriaceae", "Cyrillaceae", 
            "Garryaceae", "Magnoliaceae", "Nesogenaceae",
            "Saururaceae", "Styracaceae", "Trapaceae")

gymnosperms <- c("Pinidae",
                 "Pinophyta",
                 "Spermatophytina",
                 "Ephedraceae Dumort.")

ferns <- c("Polypodiidae", "Marattiaceae",
           "Ophioglossaceae", "Psilotaceae",
           "Polypodiopsida", "Hymenophyllaceae",
           "Psilotaceae", "Pteridaceae",
           "Salviniaceae", "Pteridophyta")

tibble(taxonomic_group = c("birds",
                           "mammals",
                           "reptiles",
                           "amphibians",
                           "fish",
                           "dicots",
                           "monocots",
                           "ferns",
                           "gymnosperms"), 
       ala_classification = c("aves",
                              "mammalia",
                              "reptilia",
                              "amphibia",
                              list(fish),
                              list(dicots),
                              list(monocots),
                              list(ferns),
                              list(gymnosperms))) |> 
  unnest(cols = c(ala_classification)) |> 
  write_csv(here("output",
                 "taxon_reference.csv"))
