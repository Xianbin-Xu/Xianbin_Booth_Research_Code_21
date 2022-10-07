#!/bin/sh

#SBATCH --partition=covert-dingel
#SBATCH --job-name=OSM_feature_process_by_state
#SBATCH --output=slurmlogs/OSM_feature_process_by_state.out
#SBATCH --error=slurmlogs/OSM_feature_process_by_state.err
#SBATCH --time=0:15:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=8g
#SBATCH --mail-type=FAIL

module load R/4.0.0
module load gdal/2.4.1
module load udunits
R < $1 --no-save --args $2
