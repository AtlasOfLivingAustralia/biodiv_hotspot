# libraries, options, config --------
{
  library(galah)
  library(here)
  library(tidyverse)
  library(janitor)
  library(sf)
  library(ozmaps)
  library(rfishbase)
}

conflicted::conflicts_prefer(dplyr::filter, tidyr::unnest)

galah_config(email = Sys.getenv("ALA_EMAIL"))

source("scripts/functions.R")

# reference tables, preprocessing ------
taxon_lookup <- read_csv(here("data", "taxon_lookup.csv"))

# regions
ibra_lookup <- tibble(region_name = c("Wet Tropics",
                                      "Central Mackay Coast",
                                      "South Eastern Queensland",
                                      "Nandewar",
                                      "New England Tablelands",
                                      "NSW North Coast",
                                      "Sydney Basin"),
                      ecoregion_type = c(rep("tropics", 2),
                                         rep("temperate", 5)))

hotspot_regions <- ibra_lookup$region_name
tropics_regions <- ibra_lookup$region_name[ibra_lookup$ecoregion_type == "tropics"]
temperate_regions <- ibra_lookup$region_name[ibra_lookup$ecoregion_type == "temperate"]

# fish habitats lookup (needs to be redone if list of fish changes)
fish_habitats <- readRDS("data/processed/fish_habitats.RDS")

# projections are to Australian Albers Equal-Area CRS 3577
st_read(here("data", "ibra7", "ibra7_regions.shp")) |>
  filter(REG_NAME_7 %in% ibra_lookup$region_name) |>
  select(REG_NAME_7) |>
  st_transform(crs = 3577) |> 
  saveRDS(here("data", "processed", "hotspot_sf.RDS"))

st_read(here("data", "ibra7", "ibra7_regions.shp")) |>
  filter(REG_NAME_7 %in% ibra_lookup$region_name[ibra_lookup$ecoregion_type=="tropics"]) |>
  select(REG_NAME_7) |>
  st_transform(crs = 3577) |> 
  saveRDS(here("data", "processed", "tropics_sf.RDS"))

st_read(here("data", "ibra7", "ibra7_regions.shp")) |>
  filter(REG_NAME_7 %in% ibra_lookup$region_name[ibra_lookup$ecoregion_type=="temperate"]) |>
  select(REG_NAME_7) |>
  st_transform(crs = 3577) |> 
  saveRDS(here("data", "processed", "temperate_sf.RDS"))

# griis version 1.10 from GBIF
griis_list <- read_tsv(here("data", "dwca-griis-australia-v1", "taxon.txt"))

search_taxa_griis <- griis_list |>
  filter(kingdom == "Plantae" | kingdom == "Animalia") |> 
  select(kingdom, phylum, class, order, family, scientificName) |>
  group_split(scientificName) |> 
  map(\(df)
      df |>
        search_taxa()) |> 
  bind_rows() 

griis_list_matched <- search_taxa_griis |> 
  filter(match_type %in% c("canonicalMatch", "exactMatch", "fuzzyMatch"),
         issues %in% c("noIssue", "parentChildSynonym"), 
         !is.na(species)) |> 
  select(search_term, scientific_name, taxon_concept_id) |> 
  mutate(search_term_last = str_split_i(search_term, "_", -1)) |>
  left_join(griis_list,
            by = join_by(search_term_last == scientificName)) |> 
  select(scientific_name) |> 
  distinct() 

saveRDS(griis_list_matched, here("data", "processed", "griis_list_matched.RDS"))