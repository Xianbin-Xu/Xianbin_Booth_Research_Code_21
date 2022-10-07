## Task Description

- Author: Xianbin Xu.
- Last updated: 02/03/2022.
- Purpose: this task merges shapefile consisting checkposts downloaded from OSM
- Input: shapefile of checkposts in each states, from OSM_feature_process_by_state
- Output: a shapefile containing locations, names, state they are in, and distance to state border, for each checkpost (format: points)

## Notes

- Algorithm: Simply use rbind for each files.
- We got 10,466 entries in output, amongst which 2,277 are registered with a name, 3,100 is within 10,000 meters from state borders, and only 616 fits both criterion.

## Columns of output data

- name: character, name of the checkpost. NA if no name from OSM.
- catgTyp: character, type of the entry. 
  - AP: key = "amenity", value = "police"
  - BT: key = "barrier", value = "toll_booth"
  - BB: key = "barrier", value = "border_control"
  - MC: key = "military", value = "checkpoint"
- StateNm: Name of the state the checkpost is in
- is_n_st: 1 if is within state. 0 if outside state. Used in OSM_feature_process_by_state. Only contains 1 in output.
- dst2brd: distance to state border, in meters.
