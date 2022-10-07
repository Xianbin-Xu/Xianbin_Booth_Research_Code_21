## Task Description

- Author: Xianbin Xu.
- Last updated: 02/03/2022.
- Purpose: this task downloads point checkpost data from OSM
- Input: Nothing
- Output: A shapefile containing checkpost locations for each state (format: points)

## Notes

- Algorithm: for each state, use getbb to find bounding box around a state, then do
  opq and add_osm_feature to designate the datapoints to be downloaded.

- The whole process took 15 minutes for all the states.
  OSM API might go offline sometime, but tasks are continued without disruption with Makefile.
  The code is volatile and sometimes should be ran several times.

- Since a bounding box is a rectangle that contains a state, and OSM would download everything
  in the bounding box, there are points outside the state for each state. Such problem will be solved in later
  OSM_feature_process_by_state script.

- Format of the output:
  - Name: name of the point.
  - categType: category of this entry. MC: Military Checkpoint. AP: Amenity-Police.
  - BT: Barrier-Toll Booth, BB-Barrier-Border Control.
  - StateName: name of the state used to call OSM feature download.

- Since bounding box include area larger than state itself, our features can
  be outside state indicated by this column.