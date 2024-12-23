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
