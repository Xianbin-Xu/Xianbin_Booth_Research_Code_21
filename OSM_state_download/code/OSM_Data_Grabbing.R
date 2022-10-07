# Packages
library(tidyverse)
library(sf)
library(osmdata)
library(stringr)
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
#------------------------------------------------------------------------------

# Columns to be included.
columns_to_include <- c(
  "osm_id", "name", "ISO3166-2", "admin_level",
  "boundary", "in_country_code", "geometry"
)

# Function: gather a shapefile for a selected state.
# Make sure your input name matches the OSM name perfectly.
# Admin level: 2 for whole country, 4 for state or union territory.

OSM_grab <- function(name, admin_level) {
  GG <- getbb(name) %>%
    opq() %>%
    add_osm_feature(key = "admin_level", value = admin_level) %>%
    add_osm_feature(key = "is_in:country_code", value = "IN")
  GG <- GG %>%
    osmdata_sp()
  GG_shape <- st_as_sf(GG$osm_multipolygons) # CRS is 4326
  GG_shape <- GG_shape[GG_shape$name == name,
                       names(GG_shape) %in% columns_to_include]

  return(GG_shape)
}

# Function: grab states by state code and name.
OSM_grab_by_code <- function(name, code, admin_level) {
  GG <- getbb(name) %>%
    opq() %>%
    add_osm_feature(key = "admin_level", value = admin_level) %>%
    add_osm_feature(key = "ISO3166-2", value = code)
  GG <- GG %>%
    osmdata_sp()
  GG_shape <- st_as_sf(GG$osm_multipolygons)
  GG_shape <- GG_shape[, names(GG_shape) %in% columns_to_include]
  return(GG_shape)
}

# Technical notes:

# Question: Why must I include is_in:country_code,
# even if sometimes it's NA For an undisputed place like Goa?
# Answer: Sometimes without this line st_as_sf throw an error,
# so I plugged it in. Plus, it narrows down the range.

# Question: Why osmdata_sp instead of sf?
# Answer: For some reason, sf gives a C stack too close to limit error
# whenever trying to plot or even view the sf object.
# I thus decided to instead use SP first then transform to SF.
# It's gross but it works.

# Sometimes, for some state, the is_in Country code section is blank.
# in this case, we cannot extract its shapefile.
# We, however, listed out these states.
# "IN-JK", "IN-UT", "IN-GA", "IN-LA"


#Load State Code and Name Correspondence.
State_Code_Name <- data.frame(matrix(ncol = 2, nrow = 34))
colnames(State_Code_Name) <- c("Name", "Code")

State_Code_Name$Name <- c(
  "Andhra Pradesh", "Arunachal Pradesh",
  "Assam", "Bihar", "Chandigarh",
  "Chhattisgarh", "Dadra and Nagar Haveli and Daman and Diu",
  "Delhi", "Goa", "Gujarat", "Haryana", "Himachal Pradesh",
  "Jammu and Kashmir", "Jharkhand", "Karnataka",
  "Kerala", "Ladakh", "Madhya Pradesh", "Maharashtra",
  "Manipur", "Meghalaya", "Mizoram", "Nagaland",
  "Odisha", "Puducherry", "Punjab", "Rajasthan",
  "Sikkim", "Tamil Nadu", "Telangana", "Tripura",
  "Uttar Pradesh", "Uttarakhand", "West Bengal"
)

State_Code_Name$Code <- c(
  "IN-AP", "IN-AR", "IN-AS", "IN-BR",
  "IN-CH", "IN-CT", "NA", "IN-DL",
  "IN-GA", "IN-GJ", "IN-HR", "IN-HP",
  "IN-JK", "IN-JH", "IN-KA", "IN-KL",
  "IN-LA", "IN-MP", "IN-MH", "IN-MN",
  "IN-ML", "IN-MZ", "IN-NL", "IN-OR",
  "IN-PY", "IN-PB", "IN-RJ", "IN-SK",
  "IN-TN", "IN-TG", "IN-TR", "IN-UP",
  "IN-UT", "IN-WB"
)

#------------------------------------------------------------------------------
# 2. Download data
#------------------------------------------------------------------------------

print(state_name_to_download)

# Download data
if (state_name_to_download != "Dadra and Nagar Haveli and Daman and Diu") {
    matched_index <- match(state_name_to_download, State_Code_Name$Name)
    statecode <- State_Code_Name$Code[matched_index]
    OSM_fromAPI <- OSM_grab_by_code(state_name_to_download, statecode, 4)
  } else{
    OSM_fromAPI <- OSM_grab(state_name_to_download, 4)
  }
  OSM_fromAPI$in_country_code <- "IN"

# Replace whitespaces with underscores
state_name_to_download <- str_replace_all(state_name_to_download, " ", "_")

# Save the shapefile
filename <- paste("../output/OSM_", state_name_to_download, ".shp", sep = "")
st_write(OSM_fromAPI, filename, append = FALSE)

# Sleep in case the script runs too fast
Sys.sleep(5)