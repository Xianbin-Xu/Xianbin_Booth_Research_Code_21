#!/bin/sh

#SBATCH --partition=covert-dingel
#SBATCH --job-name=OSM_download_data
#SBATCH --output=slurmlogs/%x_%j.out
#SBATCH --error=slurmlogs/%x_%j.err
#SBATCH --time=00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=8g
#SBATCH --mail-type=END,FAIL

module load R/4.0.0
module load gdal/2.4.1
module load udunits

R < $1 --no-save --args $2