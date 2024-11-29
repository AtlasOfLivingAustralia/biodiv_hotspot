get_n_species <- function(taxon) {
  
  galah_call() |> 
    identify(taxon) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950,
           cl1048 %in% ibra) |> 
    atlas_species()
  
}

get_all_counts <- function(taxonID) {
  
  galah_call() |> 
    identify(taxonID) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950) |>
    atlas_counts()
  
}

get_ibra_counts <- function(taxonID) {
  
  galah_call() |> 
    identify(taxonID) |> 
    galah_apply_profile(ALA) |> 
    filter(year >= 1950,
           cl1048 %in% ibra) |>
    atlas_counts()
  
}
