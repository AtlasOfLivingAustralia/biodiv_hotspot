# libraries, options, config --------
{
  library(galah)
  library(here)
  library(dplyr)
  library(readr)
  library(purrr)
  library(janitor)
  library(sf)
  library(ozmaps)
}

galah_config(email = Sys.getenv("ALA_EMAIL"))
#sf_use_s2(FALSE)
conflicted::conflicts_prefer(
  dplyr::filter,
  tidyr::unnest
)

source("functions.R")

# identify IBRA --------
# figure out which of the IBRA regions correspond to the Forests of East 
# Australia hotspot 
ea_hotspot <- st_read(here("data",
                           "spatial",
                           "hotspots_2016_1",
                           "hotspots_2016_1.shp")) |>
  filter(NAME == "Forests of East Australia")

ibra <- st_read(here("data",
                     "spatial",
                     "ibra7",
                     "ibra7_regions.shp")) |> 
  st_transform(4326)

ibra |> 
  st_intersection(ea_hotspot) |> 
  select(REG_NAME_7) |> 
  saveRDS(here("data",
               "spatial",
               "ibra_hotspot.RDS"))
