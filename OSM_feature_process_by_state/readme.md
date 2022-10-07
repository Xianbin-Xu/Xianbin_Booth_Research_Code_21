## Task Description

- Author: Xianbin Xu.
- Last updated: 02/03/2022.
- Purpose: this task discards checkpost outside the state for each state, and calculate their distance from state border
- Input: shapefile for state borders from OSM_state_download, and shapefile for checkpost locations from OSM_feature_download_raw
- Output: shapefile of all checkposts in a state, for each state.

## Notes

- Algorithm: for each state, use st_intersect to find the list of checkposts within each state, discard those outside the state, and use st_distance to calculate distance from border.
- Runtime is very short, for all 34 states added together.
- We assume no checkpost exist exactly in state border as the chance is very low.
- Checkposts in state border, should there be any, would be counted twice. This is not a big problem.