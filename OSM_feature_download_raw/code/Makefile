# Definitions
STATE_LIST = Andhra_Pradesh Arunachal_Pradesh Assam Bihar Chandigarh \
	Chhattisgarh Dadra_and_Nagar_Haveli_and_Daman_and_Diu Delhi Goa Gujarat \
	Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala \
	Ladakh Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Nagaland Odisha \
	Puducherry Punjab Rajasthan Sikkim Tamil_Nadu Telangana Tripura \
	Uttar_Pradesh Uttarakhand West_Bengal

all: $(foreach state, $(STATE_LIST), ../output/OSM_features_$(state).shp)

../output/OSM_features_%.shp: OSM_Feature_Download.R | ../output slurmlogs
	if command -v sbatch > /dev/null; then sbatch -W run.sbatch '$<' '$*'; else R < $< --no-save --args '$*'; fi

#Folder recipes
../output slurmlogs:
	mkdir $@