#Definitions
SHP_EXT =  .dbf .prj .shp .shx
INPUTS1 = $(addprefix ../input/roads_osm, $(SHP_EXT))
INPUTS2 = $(addprefix ../input/OSM_fromAPI, $(SHP_EXT))
INPUTS3 = $(addprefix ../input/OSM_intersection, $(SHP_EXT))
INPUTS4 = $(addprefix ../input/Admin2, $(SHP_EXT))
INPUTS5 = $(addprefix ../input/SOI_state_shapefile, .dbf .shp .shx)
INPUTS6 = $(addprefix ../input/IND_v34_adm_1, $(SHP_EXT))

all: ../output/bc_areas.pdf

../output/bc_areas.pdf: OSM_Inter_Drawing_new.R $(INPUTS1) $(INPUTS2) $(INPUTS3) $(INPUTS4) $(INPUTS5) $(INPUTS6) ../input/google_maps_API.R  ../input/gtrac_clusters_basicinfo.csv | ../output
	if command -v sbatch > /dev/null; then sbatch -W run.sbatch '$<'; else R < $< --no-save; fi

#Input recipes
../input/roads_osm.%: ../../OSM_process_data/output/roads_osm.% | ../input
	ln -s $< $@

../input/OSM_fromAPI.%: ../../OSM_state_merge/output/OSM_fromAPI.% | ../input
	ln -s $< $@

../input/OSM_intersection.%: ../../OSM_intersect_roads_borders/output/OSM_intersection.% | ../input
	ln -s $< $@

../input/gtrac_clusters_basicinfo.csv: ../../GTrac_crossing_clusters/output/gtrac_clusters_basicinfo.csv | ../input 
	ln -s $< $@

../input/Admin2.%: ../../download_data/output/Admin2.% | ../input
	ln -s $< $@ 

../input/SOI_state_shapefile.%: ../../SOIshp_transform_statelevel/output/SOI_state_shapefile.% | ../input
	ln -s $< $@

../input/IND_v34_adm_1.%: ../../download_data/output/IND_v34_adm_1.% | ../input
	ln -s $< $@

../input/google_maps_API.R: ../../proprietary_data/output/google_maps_API.R | ../input
	ln -s $< $@

#Folder recipes
../input ../output slurmlogs:
	mkdir $@

# Upstream recipes
../../%: #Generic recipe to produce outputs from upstream tasks
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)