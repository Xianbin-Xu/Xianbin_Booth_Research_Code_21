#Definitions

EXTENSIONS = dbf prj shp shx

STATE_LIST = Andhra_Pradesh Arunachal_Pradesh Assam Bihar Chandigarh \
	Chhattisgarh Dadra_and_Nagar_Haveli_and_Daman_and_Diu Delhi Goa Gujarat \
	Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala \
	Ladakh Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Nagaland Odisha \
	Puducherry Punjab Rajasthan Sikkim Tamil_Nadu Telangana Tripura \
	Uttar_Pradesh Uttarakhand West_Bengal

INPUTS = $(foreach ext,$(EXTENSIONS),$(foreach state,$(STATE_LIST),../input/OSM_features_processed_$(state).$(ext)))

all: ../output/OSM_features.csv

# Output recipies
../output/OSM_features.csv: OSM_Feature_Merge.R $(INPUTS) | ../output
	if command -v sbatch > /dev/null; then sbatch -W run.sbatch '$<' '$*'; else R < $< --no-save; fi

# Input recipies
../input/OSM_features_processed_%: ../../OSM_feature_process_by_state/output/OSM_features_processed_% | ../input
	ln -s $< $@

#Folder recipes
../input ../output slurmlogs:
	mkdir $@

# Upstream recipes
../../%: #Generic recipe to produce outputs from upstream tasks
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)