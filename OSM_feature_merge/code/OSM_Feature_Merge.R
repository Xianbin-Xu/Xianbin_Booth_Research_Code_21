library(sf)
library(tidyverse)

# Set the working directory
if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

list_o_states <- c(
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

filename <- paste("../input/OSM_features_processed_",
                  list_o_states[1], ".shp", sep = "")

df <- st_read(filename)

for (i in 2:length(list_o_states)) {
  filename <- paste("../input/OSM_features_processed_",
                    list_o_states[i], ".shp", sep = "")
  df <- rbind(df, st_read(filename))
  if (i %% 10 == 0) {
    print(paste(i, "th state finished merging!"))
  }
}

# Extract the coordinates
df$lon <- st_coordinates(df)[, 1]
df$lat <- st_coordinates(df)[, 2]
st_geometry(df) <- NULL

# Save the data
write_csv(df, "../output/OSM_features.csv", na = "")
