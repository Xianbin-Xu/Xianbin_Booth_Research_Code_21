library(sf)

# Set the working directory
if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

# State shapefiles to append
list_states <- c(
  "Andhra_Pradesh", "Arunachal_Pradesh",
  "Assam", "Bihar", "Chandigarh",
  "Chhattisgarh", "Dadra_and_Nagar_Haveli_and_Daman_and_Diu",
  "Delhi", "Goa", "Gujarat", "Haryana",
  "Himachal_Pradesh", "Jammu_and_Kashmir",
  "Jharkhand", "Karnataka", "Kerala",
  "Ladakh", "Madhya_Pradesh",
  "Maharashtra", "Manipur", "Meghalaya",
  "Mizoram", "Nagaland",
  "Odisha", "Puducherry", "Punjab",
  "Rajasthan", "Sikkim", "Tamil_Nadu",
  "Telangana", "Tripura", "Uttar_Pradesh",
  "Uttarakhand", "West_Bengal"
)

# Load the first state shapefile
filename <- paste("../input/OSM_", list_states[1], ".shp", sep = "")
osm_shapefile_state <- st_read(filename)

# Load the remaining state shapefiles and append into one df
for (i in 2:length(list_states)) {
  filename <- paste("../input/OSM_", list_states[i], ".shp", sep = "")
  osm_shapefile_state <- rbind(osm_shapefile_state, st_read(filename))
}

# Write the resulting shapefile
st_write(osm_shapefile_state, "../output/OSM_fromAPI.shp", append = FALSE)
