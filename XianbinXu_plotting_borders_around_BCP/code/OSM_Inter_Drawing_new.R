library(tidyverse)
library(sf)
library(sp)
library(ggplot2)
library(ggmap)
library(ggthemes)
library(geohashTools)
library(gridExtra)

# Set the working directory
if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

# Load inputs

##I 
#Whatever came in that zip file, including state borders
#From OSM, Datameet, Survey of India, and GDAM
#Also have road(which took most the space)
#And the list of points for centers of drawing.

# TODO: Please use <- for assignment (everywhere)
# TODO: Please fix the coding style to alighn with https://style.tidyverse.org/syntax.html
# TODO: When using ggplot2, please adhere to this style https://style.tidyverse.org/ggplot2.html
# TODO: Please divide the code on 
#sections so it is easier to follow (load data, process data, create plots, etc.)


#-------------------------------------------------------------------------------
######Part 1: Load Data


Roads <- st_read("../input/roads_osm.shx")

#Our OSM data
OSM_States <- st_read("../input/OSM_fromAPI.shx")

OSM_borders <- st_cast(OSM_States, "MULTILINESTRING", group_or_split = FALSE)

#The Datameet Data
DataMeet_States <- st_read("../input/Admin2.shx")

DataMeet_States <- DataMeet_States[DataMeet_States$ST_NM != "Andaman & Nicobar" 
                                  & DataMeet_States$ST_NM != "Lakshadweep", ]

DataMeet_borders <- st_cast(DataMeet_States, "MULTILINESTRING", group_or_split = FALSE)

#Survey of India data
SOI_States <- st_read("../input/SOI_state_shapefile.shp")

SOI_States <- SOI_States[SOI_States$Names != "ANDAMAN AND NICOBAR" &
                          SOI_States$Names != "LAKSHADWEEP", ]
st_crs(SOI_States) <- 4326
SOI_borders <- st_cast(SOI_States, "MULTILINESTRING", group_or_split = FALSE)

#GDAM Data
GDAM_States <- st_read("../input/IND_v34_adm_1.shx")

GDAM_States <- GDAM_States[GDAM_States$NAME_1 != "Andaman and Nicobar" 
                          & GDAM_States$NAME_1 != "Lakshadweep", ]
GDAM_borders <- st_cast(GDAM_States, "MULTILINESTRING", group_or_split = FALSE)

#List of our intersections
#That is the CSV file given to us with bunch of Border Crossing pins.
list_o_intersections <- read.csv("../input/gtrac_clusters_basicinfo.csv",
                                stringsAsFactors = FALSE)
#Points of intersections
OSM_Int_smallPt <- st_read("../input/OSM_intersection.shx")

# Google Maps API key
source("../input/google_maps_API.R")
register_google(key)

# TODO: I uncommented this line because it is used in the code 
# below and the code returned an error. 
# TODO: What was the reason to comment out this line?
# I did this line to prevent having multi-points in intersections
# Giving Errors. I believe that right now OSM_Int_Point consists
# Only points but no multi-points in OSM_Int_Pt now.
# I think the error was due to different variable names .
# Fixed by changing variable name above.

# OSM_Int_smallPt = st_cast(OSM_Int_Pt, "POINT")

#Processing the list of intersection to a shape file from a CSV
for(i in 1:nrow(list_o_intersections)){
  list_o_intersections$geometry[i] =
    st_sfc(st_point(c(list_o_intersections$lon[i], 
                      list_o_intersections$lat[i]),
                    dim = "XY"))
}

list_o_intersections = st_as_sf(list_o_intersections)
st_crs(list_o_intersections) = 4326

#-------------------------------------------------------------------------------
######Part 2: Functions

GGDrawer_Google <- function(Center, width_half = 3000, 
                            google_maptype = c("terrain","satellite", 
                                               "roadmap", "hybrid")){
  #Center shall be a point.
  #half width: In meters, above and below
  #default: 3000
  #RID stands for Range in Degree
  
  #Legend:
  #Ugly Big Black Dot: the location provided by CSV file.
  #Smaller Black Dot: Intersect of OSM states and roads
  #Bold think black line: roads provided by OSM
  #Red Line: Open Street map states
  #Blue Line: Datameet data
  #Cyan Line: Survey of India
  #Purple Line: GDAM
  #Hell I wished I've taken my art core before this, instead of after.
  
  RID <- width_half/111000
  
  Cent_X <- st_coordinates(Center)[1]
  Cent_Y <- st_coordinates(Center)[2]
  XMin <- Cent_X - RID
  XMax <- Cent_X + RID
  YMin <- Cent_Y - RID
  YMax <- Cent_Y + RID
  Zoom <- calc_zoom(lon = c(XMin, XMax), lat = c(YMin, YMax))

  #Google Map
  GG_Base_Map <- get_googlemap(c(Cent_X, Cent_Y), Zoom, maptype = google_maptype)
  
  #Rectangle to be drawn
  rec_matrix_X <- c(XMin, XMax, XMax, XMin, XMin)
  rec_matrix_Y <- c(YMin, YMin, YMax, YMax, YMin)
  rec_matrix <- matrix(c(rec_matrix_X, rec_matrix_Y), ,2)
  rec <- st_polygon(list(st_linestring(rec_matrix))) %>% st_sfc(crs = 4326)
  
  Int_in_area = st_intersection(rec, OSM_Int_smallPt)
  
  #Sometimes, we have NO OSM intersection in the area.
  #It may cause problem
  #thus if its length's 0--meaning no intersection--
  #We use another function.
  #Basically the same, only difference is that
  #geom_sf of the point is deleted.
  if(length(Int_in_area) > 0){
    Great_Map <- GGPLot_Draw_Normal(GG_Base_Map, Center, rec, Int_in_area)
  }
  else if(length(Int_in_area) == 0){
    Great_Map <- GGPLot_Draw_NoInt(GG_Base_Map, Center, rec)
  }
  #Draw this thing
  
  return(Great_Map)
}

#Plot the roads over Google's layer.
GGPLot_Draw_Normal <- function(GG_Base_Map, Center, rec, Int_in_area){
  Great_Map <- ggmap(GG_Base_Map) +
    geom_sf(data = st_intersection(rec, OSM_borders),
            inherit.aes = FALSE,  alpha = .8,
            linetype = "dotdash", col = "red",   
            aes(col= "Open Street Map Borders"), 
            show.legend = "Open Street Map Borders") +
    geom_sf(data = st_intersection(rec, SOI_borders),
            inherit.aes = FALSE, col = "#E69F00", 
            aes(col= "Survey of India Borders")) +
    geom_sf(data = st_intersection(rec, DataMeet_borders),
            inherit.aes = FALSE, linetype = "dotted", 
            alpha = .8, col = "blue", 
            aes(col= "Datameet Borders"))  +
    geom_sf(data = st_intersection(rec, GDAM_borders),
            inherit.aes = FALSE, col = "#009E73", 
            aes(col= "GDAM Borders"))  +
    geom_sf(data = st_intersection(rec, Roads),
            inherit.aes = FALSE, shape = 7, 
            aes(col= "Open Street Map Roads"), 
            alpha = .9, col = "gray20") +
    geom_sf(data = Center, 
            inherit.aes = FALSE, col = "gray10", size = 6, 
            aes(shape = "Truck Data BCP")) +
    geom_sf(data = Int_in_area,
            inherit.aes = FALSE, 
            aes(shape = "OSM Intersections"), 
            size = 6,
            col = "black") +
    scale_shape_manual(name = "Border Crossing Points(Pins)",
                       values = c("Truck Data BCP" = 8, "OSM Intersections" = 13),
                       guide = guide_legend(override.aes = 
                                              list(col = c("gray10", "black"),
                                                   linetype = c("blank", "blank"),
                                                   size = 6, fill = NA))) +
    scale_colour_manual(name = "borders",
                        values = c("Open Street Map Borders" = "red",
                                   "Survey of India Borders" =  "#E69F00",
                                   "Datameet Borders" = "blue",
                                   "GDAM Borders" = "#009E73",
                                   "Open Street Map Roads" = "gray20"),
                        guide = guide_legend(override.aes = 
                              list(col = 
                                c("red",  "#E69F00", 
                                  "blue", "#009E73", 
                                  "gray20"),
                                linetype = 
                                c("dotdash", "solid", 
                                  "dotted", "solid", "solid"),
                              size = 6)))
  
  return(Great_Map)
}


#Plot the roads over Google's layer.
#No intersection point this time.
GGPLot_Draw_NoInt <- function(GG_Base_Map, Center, rec){
  Great_Map <- ggmap(GG_Base_Map) +
    geom_sf(data = st_intersection(rec, OSM_borders),
            inherit.aes = FALSE,  alpha = .8,
            linetype = "dotdash", col = "red",   
            aes(col= "Open Street Map Borders"), 
            show.legend = "Open Street Map Borders") +
    geom_sf(data = st_intersection(rec, SOI_borders),
            inherit.aes = FALSE, col = "#E69F00", 
            aes(col= "Survey of India Borders")) +
    geom_sf(data = st_intersection(rec, DataMeet_borders),
            inherit.aes = FALSE, linetype = "dotted", 
            alpha = .8, col = "blue", 
            aes(col= "Datameet Borders"))  +
    geom_sf(data = st_intersection(rec, GDAM_borders),
            inherit.aes = FALSE, col = "#009E73", 
            aes(col= "GDAM Borders"))  +
    geom_sf(data = st_intersection(rec, Roads),
            inherit.aes = FALSE, shape = 7, 
            aes(col= "Open Street Map Roads"), 
            alpha = .9, col = "gray20") +
    geom_sf(data = Center, 
            inherit.aes = FALSE, col = "gray10", size = 6, 
            aes(shape = "Truck Data BCP")) +
    scale_shape_manual(name = "Border Crossing Points(Pins)",
                       values = c("Truck Data BCP" = 8),
                       guide = guide_legend(override.aes = 
                                              list(col = c("gray10"),
                                                   linetype = c("blank"),
                                                   size = 6, fill = NA))) +
    scale_colour_manual(name = "borders",
                        values = c("Open Street Map Borders" = "red",
                                   "Survey of India Borders" =  "#E69F00",
                                   "Datameet Borders" = "blue",
                                   "GDAM Borders" = "#009E73",
                                   "Open Street Map Roads" = "gray20"),
                        guide = guide_legend(override.aes = 
                                      list(col = 
                                            c("red",  "#E69F00", "blue", 
                                            "#009E73", "gray20"),
                                            linetype = 
                                            c("dotdash", "solid", 
                                                "dotted", "solid", "solid"),
                                            size = 6)))
  return(Great_Map)
}

##Unecessary Codes deleted

#-------------------------------------------------------------------------------
# Part 3: save maps into separate pdf files


# Function: produce and save the map in pdf format
GGDrawer_save <- function(Center) {
  map <- GGDrawer_Google(Center, google_maptype = "roadmap") # Produce the map
  geohash <- gh_encode(st_coordinates(Center)[2], 
                       st_coordinates(Center)[1], precision = 7) 
  # Produce geohash for the border-crossing area
  filename <- paste("../output/bc_area_", geohash, ".pdf", sep = "")
  ggsave(filename, map, width = 10, height = 10) 
  # You might want to change width and height
}

# Produce a map for each border-crossing area

#-------------------------------------------------------------------------------
# Part 4: produce a single report with all maps


GGDrawer_Google_with_title <- function(Center) {
  map <- GGDrawer_Google(Center, google_maptype = "roadmap") # Produce the map
  geohash <- gh_encode(st_coordinates(Center)[2], 
                       st_coordinates(Center)[1], precision = 7)
  title <- paste("Geohash: ", geohash, sep = "")
  map <- map + labs(title = title)
  return(map)
}


#Did Lapply one by one because 
#dealing with it in a whole loop is problematic.

figures <- lapply(list_o_intersections$geometry[1:1], GGDrawer_Google_with_title)

figures[[1]] <- GGDrawer_Google_with_title(list_o_intersections$geometry[1])

for(i in 2:nrow(list_o_intersections)){
  figures[[i]] <- GGDrawer_Google_with_title(list_o_intersections$geometry[i])
  if((i %% 10) == 0){
    print(paste(i, "th plotting completed!"))
  }
}


# Save the figures into one report
ggsave(
  filename = "../output/bc_areas.pdf", 
  plot = marrangeGrob(figures, nrow=1, ncol=1), 
  width = 10, height = 10
)
#103 and 104 are problematic.

#Output:
#142 pictures--no idea what will it be.
