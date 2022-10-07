library(tidyverse)
library(sf)
library(osmdata)

#Let's also use a console-command model.

args <- commandArgs(trailingOnly = TRUE)

# Input state name from the command line
if (length(args) == 1) {
  print(args)
  state_name_to_download <- args[1]
} else {
  stop("Too few or too many arguments are passed from the command line")
}
state_name_to_download <- str_replace_all(state_name_to_download, "_", " ")
print(state_name_to_download)

# Set the working directory
if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}
# Note that we just need a list of state names from OSM to run the script.

#------------------------------------------------------------------------------
# 1. Define functions to download data

OSM_Data_Cleanser <- function(OSM_Dataset_Input, sourceType){
  New <- OSM_Dataset_Input
  if (nrow(New) == 0) {
    print(2)
    return(NULL)
  }
  if (!("name" %in% colnames(OSM_Dataset_Input))) {
    OSM_Dataset_Input$name <- NA
    return(NULL)
  }

  New$categType <- sourceType
  New <- New[, c("name", "categType")]
  return(New)
}

OSM_Grab <- function(name) {
  #Name is the name of the state.
  GG <- getbb(name) %>%
    opq() %>%
    add_osm_feature(key = "military", value = "checkpoint") %>%
    osmdata_sp()
  if(nrow(GG$osm_points) == 0) {
    GG_shape <- NULL
  }
  else{
    GG_shape <- st_as_sf(GG$osm_points)
    GG_shape <- OSM_Data_Cleanser(GG_shape, "MC")

  }

  GG <- getbb(name) %>%
    opq() %>%
    add_osm_feature(key = "amenity", value = "police") %>%
    osmdata_sp()
  if(nrow(GG$osm_points) == 0) {
    GG_shape1 <- NULL
  }
  else{
    GG_shape1 <- st_as_sf(GG$osm_points)
    GG_shape1 <- OSM_Data_Cleanser(GG_shape1, "AP")
  }
  
  GG <- getbb(name) %>%
    opq() %>%
    add_osm_feature(key = "barrier", value = "toll_booth") %>%
    osmdata_sp()
  if(nrow(GG$osm_points) == 0){
    GG_shape2 <- NULL
  }
  else{
    GG_shape2 <- st_as_sf(GG$osm_points)
    GG_shape2 <- OSM_Data_Cleanser(GG_shape2, "BT")
  }

  GG <- getbb(name) %>%
    opq() %>%
    add_osm_feature(key = "barrier", value = "border_control") %>%
    osmdata_sp()

  if (nrow(GG$osm_points) == 0) {
    GG_shape3 <- NULL
  }
  else{
    GG_shape3 <- st_as_sf(GG$osm_points)
    GG_shape3 <- OSM_Data_Cleanser(GG_shape3, "BB")
  }

  result <- rbind(GG_shape, GG_shape1, GG_shape2, GG_shape3)
  result$StateName <- name
  return(result)
}

# "military", value = "checkpoint"
# "amenity", value = "police"
# "barrier", value = "toll_booth"
# "barrier", value = "border_control"
# We download places state by state


temp <- OSM_Grab(state_name_to_download)
state_name_to_download <- str_replace_all(state_name_to_download, " ", "_")

filename <- paste("../output/OSM_features_", state_name_to_download, ".shp", sep = "")
st_write(temp, filename)

Sys.sleep(3)

quit()
#Following code is only for debugging purpose.

#States to be named.
list_o_states <- c(
  "Andhra Pradesh", "Arunachal Pradesh",
  "Assam", "Bihar", "Chandigarh",
  "Chhattisgarh", "Dadra and Nagar Haveli and Daman and Diu",
  "Delhi", "Goa", "Gujarat", "Haryana",
  "Himachal Pradesh", "Jammu and Kashmir",
  "Jharkhand", "Karnataka", "Kerala",
  "Ladakh", "Madhya Pradesh",
  "Maharashtra", "Manipur", "Meghalaya",
  "Mizoram", "Nagaland",
  "Odisha", "Puducherry", "Punjab",
  "Rajasthan", "Sikkim", "Tamil Nadu",
  "Telangana", "Tripura", "Uttar Pradesh",
  "Uttarakhand", "West Bengal"
)


for (i in 1:length(list_o_states)) {
  state_2_extract <- list_o_states[i]
  temp <- OSM_Grab(list_o_states[i])
  filename <- paste("../output/OSM_features_", list_o_states[i], ".shp", sep = "")
  st_write(temp, filename)

  print(paste(i, "th request completed..."))
  Sys.sleep(3)
}
