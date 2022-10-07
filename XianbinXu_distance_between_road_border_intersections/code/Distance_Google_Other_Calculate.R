library(tidyverse)
library(sf)
library(geohashTools)

# Set the working directory
if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}


#-------------------------------------------------------------------------------
# Part 1: Load Data
#-------------------------------------------------------------------------------

# Load inputs
OSM_Intersects <- st_read("../input/OSM_intersection.shx")

Records <- read.csv("../input/Google_Int_Coordinates_Record.csv", stringsAsFactors = FALSE)

Roads <- st_read("../input/roads_osm.shx")

#GDAM Data
GADM_states <- st_read("../input/IND_v34_adm_1.shx")
GADM_states <- GADM_states[!(GADM_states$NAME_1 %in% c("Andaman and Nicobar", "Lakshadweep")), ]
GDAM_borders <- st_cast(GADM_states, "MULTILINESTRING", group_or_split = FALSE)

#-------------------------------------------------------------------------------
# Part 2: define functions
#-------------------------------------------------------------------------------

# This is a distance that goes around every Google intersection point.
# It is used to calculate distance between Google intersection
# and other intersections.
Max_Dist <- 5000

#Buffer zone is a Max_Dist buffer around a Google Intersection.
#this function returns an intersection of roads and any borders
#Within such intersection. Primarily used for GDAM.
Trio_Intersect <- function(Buffer_Zone, Roadlane, Borders) {
  Roadlane_Intersected <- st_intersects(Buffer_Zone, Roadlane)
  temp1 <- st_intersection(Buffer_Zone, Roadlane[Roadlane_Intersected[[1]], ])
  temp2 <- st_intersection(Buffer_Zone, Borders)
  return(st_intersection(temp1, temp2))
}

#------------------------------------------------------------------------------- 
# Part 3: Nearest Intersects
#-------------------------------------------------------------------------------

#We can now begin finding nearest GADM and OSM
#Intersections within a small buffer of Google's Intersection.
for (i in 1:nrow(Records)) {

  #Convert Records of Google's Intersection to points
  GG_Intersection <- st_point(
    x <- c(Records$Manual.Lon[i], Records$Manual.Lat[i]),
    dim = "XY"
  ) %>%
    st_sfc(crs = 4326)

  #Create a buffer zone around abovesaid Google Intersection Points
  GG_buffer <- st_buffer(GG_Intersection, Max_Dist)

  #This shll provide intersection between Roads and GDAM borders
  #Within a buffer zone around google's intersection point.
  temp_Intersections <- Trio_Intersect(GG_buffer, Roads, GDAM_borders)

  #Finding the nearest intersection.
  Records$Nearest_GDAM[i] <- temp_Intersections[st_nearest_feature(GG_Intersection, temp_Intersections)]

  # Intersect the geometries
  OSM_intersect_pt_in_buffer = st_intersects(GG_buffer, OSM_Intersects)
  temp_Intersections <- st_intersection(GG_buffer, OSM_Intersects[OSM_intersect_pt_in_buffer[[1]], ])
  Records$Nearest_OSM[i] <- temp_Intersections[st_nearest_feature(GG_Intersection, temp_Intersections)]
  if (i %% 10 == 0) {
    print(paste(i, "th operation finished!"))
  }
}

Records <- Records[, -c(2:6)]
#These columns used to be distance to nearest OSM/GADM intersection
#Checked by eyeball. I'm changing to automatic distance now
#These columns came from original input files so 
#we are not removing the wrong columns

#Convert coordinates to numbers for easier use later on
for(i in 1:nrow(Records)){
  temp_Intersections <- st_coordinates(Records$Nearest_GDAM[i][[1]])
  Records$GDAM_Int_Lon[i] <- temp_Intersections[1]
  Records$GDAM_Int_Lat[i] <- temp_Intersections[2]
  temp_Intersections <- Records$Nearest_OSM[i][[1]]
  if (length(temp_Intersections) == 0) {
    Records$OSM_Int_Lon[i] <- NA
    Records$OSM_Int_Lat[i] <- NA
  } else {
    Records$OSM_Int_Lon[i] <- temp_Intersections[[1]][1]
    Records$OSM_Int_Lat[i] <- temp_Intersections[[1]][2]
  }
}

Record_Shape <- st_as_sf(Records, crs = 4326)

# Row 39 and 40 contains multi-points. We have multiple intersections
# between GADM and Google's intersection points. We pick the nearest one.
for (i in 1:nrow(Record_Shape)){
  Record_Shape$GG_Inter[i] <- st_point(
    x = c(Records$Manual.Lon[i], Records$Manual.Lat[i]), dim = "XY") %>%
    st_sfc(crs = 4326)

  if(class(Record_Shape$Nearest_GDAM[i])[1] == "sfc_MULTIPOINT") {
    GG_Intersection <- st_point(x = c(Records$Manual.Lon[i], Records$Manual.Lat[i]), dim = "XY") %>%
      st_sfc(crs = 4326)

    temp_Intersections <- st_cast(Record_Shape$Nearest_GDAM[i], "POINT")
    Record_Shape$Nearest_GDAM[i] <- temp_Intersections[
      st_nearest_feature(GG_Intersection, temp_Intersections)]
  }
}

Record_Shape$GG_Inter <- st_sfc(Record_Shape$GG_Inter, crs = 4326)
st_crs(Record_Shape$Nearest_OSM) <- 4326

#------------------------------------------------------------------------------- 
#Part 4: calculate nearest distances
#-------------------------------------------------------------------------------

for (i in 1:nrow(Record_Shape)) {
  #Unit is meters.
  Record_Shape$GG_Dist_to_GDAM[i] <- as.numeric(st_distance(Record_Shape$GG_Inter[i], Record_Shape$Nearest_GDAM[i]))
  Record_Shape$GG_Dist_to_OSM[i] <- as.numeric(st_distance(Record_Shape$GG_Inter[i], Record_Shape$Nearest_OSM[i]))
  Record_Shape$Geohash[i] <- gh_encode(
    st_coordinates(Record_Shape$GG_Inter[i])[2],
    st_coordinates(Record_Shape$GG_Inter[i])[1], precision = 7
  )
}

#-------------------------------------------------------------------------------
# Part 5: Save the resulting data
#-------------------------------------------------------------------------------

Records <- as.data.frame(Record_Shape)
Records <- Records[, -which(names(Record_Shape) %in% c("Nearest_GDAM", "Nearest_OSM", "GG_Inter"))]
write_csv(Records, "../output/Processed_Results.csv", na = "")