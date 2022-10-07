# Definitions
EXTENSIONS = dbf prj shp shx

STATE_LIST = Andhra_Pradesh Arunachal_Pradesh Assam Bihar Chandigarh \
	Chhattisgarh Dadra_and_Nagar_Haveli_and_Daman_and_Diu Delhi Goa Gujarat \
	Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala \
	Ladakh Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Nagaland Odisha \
	Puducherry Punjab Rajasthan Sikkim Tamil_Nadu Telangana Tripura \
	Uttar_Pradesh Uttarakhand West_Bengal

all: $(foreach state, $(STATE_LIST), ../output/OSM_features_processed_$(state).shp)

INPUTS1 = $(foreach ext,$(EXTENSIONS),$(foreach state,$(STATE_LIST),../input/OSM_$(state).$(ext)))
INPUTS2 = $(foreach ext,$(EXTENSIONS),$(foreach state,$(STATE_LIST),../input/OSM_features_$(state).$(ext)))

# Output recipies
../output/OSM_features_processed_%.shp: OSM_Feature_Process_by_State.R $(INPUTS1) $(INPUTS2) | ../output slurmlogs
	if command -v sbatch > /dev/null; then sbatch -W run.sbatch '$<' '$*'; else R < $< --no-save --args '$*'; fi

# Input recipies
../input/OSM_features_%: ../../OSM_feature_download_raw/output/OSM_features_% | ../input
	ln -s $< $@

../input/OSM_%: ../../OSM_state_download/output/OSM_% | ../input
	ln -s $< $@

#Folder recipes
../input ../output slurmlogs:
	mkdir $@

# Upstream recipes
../../%: #Generic recipe to produce outputs from upstream tasks
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)