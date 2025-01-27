# This script runs checks on the species richness datasets
# 1. number of species in hotspot == number of species in both ecoregions
# 2. identical species composition in hotspot and both ecoregions

# vertebrates ------
vert_hotspot_spp <- readRDS(here("data", "processed", "vertebrates_hotspot.RDS")) |> 
  map(pluck, "species_name") |> 
  unlist()

vert_tropics_spp <- readRDS(here("data", "processed", "vertebrates_tropics.RDS")) |> 
  map(pluck, "species_name") |> 
  unlist()

vert_temperate_spp <- readRDS(here("data", "processed", "vertebrates_temperate.RDS")) |> 
  map(pluck, "species_name") |> 
  unlist()

vert_ecoregions_spp <- c(vert_tropics_spp, vert_temperate_spp)

length(vert_hotspot_spp) == length(unique(vert_ecoregions_spp)) 
setequal(vert_hotspot_spp, vert_ecoregions_spp)


# vascular plants -------- 
# ~ 100 duplicates across the different ala classification groups, so collapse
# into the four categories of interest and remove duplicates before running
# checks
vasc_hotspot_spp <- reclassify_groups("vascular_plants_hotspot.RDS") |> 
  map(pluck, "species_name") |> 
  unlist()

vasc_tropics_spp <- readRDS(here("data", "processed", "vascular_plants_tropics.RDS")) |> 
  map(pluck, "species_name") |> 
  unlist()

vasc_temperate_spp <- readRDS(here("data", "processed", "vascular_plants_temperate.RDS")) |> 
  map(pluck, "species_name") |> 
  unlist()

vasc_ecoregions_spp <- c(vasc_tropics_spp, vasc_temperate_spp)

length(vasc_hotspot_spp) == length(unique(vasc_ecoregions_spp)) 
setequal(vasc_hotspot_spp, vasc_ecoregions_spp)
