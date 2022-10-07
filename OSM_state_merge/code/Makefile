#Definitions
EXTENSIONS = dbf prj shp shx

STATE_LIST = Andhra_Pradesh Arunachal_Pradesh Assam Bihar Chandigarh \
	Chhattisgarh Dadra_and_Nagar_Haveli_and_Daman_and_Diu Delhi Goa Gujarat \
	Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala \
	Ladakh Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Nagaland Odisha \
	Puducherry Punjab Rajasthan Sikkim Tamil_Nadu Telangana Tripura \
	Uttar_Pradesh Uttarakhand West_Bengal

INPUTS = $(foreach ext,$(EXTENSIONS),$(foreach state,$(STATE_LIST),../input/OSM_$(state).$(ext)))

all: $(addprefix ../output/OSM_fromAPI.,$(EXTENSIONS))

../output/OSM_fromAPI.%: OSM_state_merge.R $(INPUTS) | ../output
	if command -v sbatch > /dev/null; then sbatch -W run.sbatch '$<'; else R < $< --no-save; fi

../input/OSM%: ../../OSM_state_download/output/OSM% | ../input
	ln -s $< $@

#Folder recipes
../input ../output slurmlogs:
	mkdir $@

# Upstream recipes
../../%: #Generic recipe to produce outputs from upstream tasks
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)