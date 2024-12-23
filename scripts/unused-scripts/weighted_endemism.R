library(phyloregion)
library(terra)
data(africa)
p <- vect(system.file("ex/sa.json", package = "phyloregion"))
Endm <- weighted_endemism(africa$comm)
m <- merge(p, data.frame(grids=names(Endm), WE=Endm), by="grids")


amphib <- galah_call() |> 
  identify("amphibia") |> 
  galah_apply_profile(ALA) |> 
  filter(year >= 1950, countryCode == "AU") |> 
  select(species, decimalLongitude, decimalLatitude) |> 
  atlas_occurrences() |> 
  filter(species %in% frogs$species_name) 

frog_pt <- points2comm(dat = amphib, 
                       lon = "decimalLongitude", 
                       lat = "decimalLatitude", 
                       res = 0.5)

frog_endm <- weighted_endemism(frog_pt$comm_dat)
plotty <- merge(frog_pt$map, 
                data.frame(grids=names(frog_endm), WE=frog_endm), 
                by="grids")
plot(plotty, "WE")

     