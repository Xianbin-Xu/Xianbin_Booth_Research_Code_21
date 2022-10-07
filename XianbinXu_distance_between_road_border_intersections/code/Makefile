#Definitions
INPUTS1 = $(addprefix ../input/roads_osm, .dbf .prj .shp .shx)
INPUTS2 = $(addprefix ../input/IND_v34_adm_1, .dbf .prj .shp .shx)
INPUTS3 = $(addprefix ../input/OSM_intersection, .dbf .prj .shp .shx)

all: ../output/Processed_Results.csv

# Outputs recipes
../output/Processed_Results.csv: Distance_Google_Other_Calculate.R $(INPUTS1) $(INPUTS2) $(INPUTS3) ../input/Google_Int_Coordinates_Record.csv | ../output
	if command -v sbatch > /dev/null; then sbatch -W run.sbatch '$<'; else R < $< --no-save; fi

# Input recipes
../input/roads_osm.%: ../../OSM_process_data/output/roads_osm.% | ../input
	ln -s $< $@

../input/IND_v34_adm_1.%: ../../download_data/output/IND_v34_adm_1.% | ../input
	ln -s $< $@

../input/OSM_intersection.%: ../../OSM_intersect_roads_borders/output/OSM_intersection.% | ../input
	ln -s $< $@

../input/Google_Int_Coordinates_Record.csv: ../../initial_data/output/Google_Int_Coordinates_Record.csv | ../input
	ln -s $< $@

#Folder recipes
../input ../output slurmlogs:
	mkdir $@

# Upstream recipes
../../%: #Generic recipe to produce outputs from upstream tasks
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)