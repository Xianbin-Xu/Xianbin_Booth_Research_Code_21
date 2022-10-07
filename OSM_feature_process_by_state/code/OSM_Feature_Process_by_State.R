library(sf)
args <- commandArgs(trailingOnly = TRUE)

# Input state name from the command line
if (length(args) == 1) {
  print(args)
  state_name_to_download <- args[1]
} else {
  stop("Too few or too many arguments are passed from the command line")
}


filename <- paste("../input/OSM_", state_name_to_download, ".shp", sep = "")
OSM_Shapefile <- st_read(filename)
OSM_Borderline <- st_cast(OSM_Shapefile, "MULTILINESTRING", group_or_split = FALSE)

#Tell if the place is actually in the state
filename <- paste("../input/OSM_features_", state_name_to_download, ".shp", sep = "")
temp <- st_read(filename)
temp$is_in_state <- st_intersects(temp, OSM_Shapefile$geometry)
temp$is_in_state <- as.numeric(temp$is_in_state)
temp <- temp[!is.na(temp$is_in_state), ]

#Tell the distance to borderline. We'll keep it but drop something too far from border.
#The exact number is to be determined later.
temp$dist_to_border <- st_distance(temp, OSM_Borderline$geometry[1])

OSM_fromAPI <- temp

filename <- paste("../output/OSM_features_processed_", state_name_to_download, ".shp", sep = "")

st_write(OSM_fromAPI, filename)
