# libraries, options, config --------
{
  library(galah)
  library(here)
  library(dplyr)
  library(readr)
  library(purrr)
  library(janitor)
  library(sf)
}

galah_config(email = Sys.getenv("ALA_EMAIL"))
sf_use_s2(FALSE)

source("functions.R")

# data -------
ibra <- readRDS(here("data", "spatial", "ibra_hotspot.RDS")) |> 
  pull(REG_NAME_7)




# OTHER (rename this probs)
ala_profile.R
identify_ibra.R
