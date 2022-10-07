## Task Description

- Author: Xianbin Xu.
- Last updated: 02/01/2022.
- Purpose: this task pull shapefiles from India states from OpenStreetMap.
- Output: shapefiles for 34 inland states.

## Notes

- The task takes 8-10 minutes to run and requires stable internet connection.
- OSM state borders does not fit state borders in Google Maps perfectly but are quite accurate when it comes to water.
- The data is directly downloaded from Overpass API (https://wiki.openstreetmap.org/wiki/Overpass_API) using package osmdata in R.
- Time period covered by the data: until 2019.