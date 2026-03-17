#!/bin/bash
#SBATCH --job-name=vep_cache_download
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 2
#SBATCH --mem=8G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH -o vep_cache_%j.out
#SBATCH -e vep_cache_%j.err

hostname
date

# Load conda & VEP environment
module load miniconda3/3.9
source /home/FCAM/rnguyen/miniconda3/bin/activate
conda activate vep_env

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Cache directory
CACHE_DIR=/home/FCAM/rnguyen/.vep
mkdir -p $CACHE_DIR

echo "Installing Homo sapiens GRCh37 cache for VEP..."

# Safe non-crashing interactive handling: echo 'n' into the installer
# This answers the prompt: "Do you wish to exit so you can get updates (y) or continue (n):"
echo "n" | vep_install \
  -a cf \
  -s homo_sapiens \
  -y GRCh37 \
  -c $CACHE_DIR

echo "Cache install finished"

echo "Installed caches:"
ls $CACHE_DIR/homo_sapiens

date
