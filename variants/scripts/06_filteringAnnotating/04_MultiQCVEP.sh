#!/bin/bash
#SBATCH --job-name=multiqc_vep
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=8G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err


date
hostname 

# Set a valid UTF-8 locale
export LANG=en_US.utf8
export LC_ALL=en_US.utf8
export LANGUAGE=en_US.utf8

# ------------------------------
# Load MultiQC module
# ------------------------------
module load MultiQC/1.15

# ------------------------------
# VEP output directory (where all stats_file HTMLs are)
# ------------------------------
VEP_DIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/06_Annotate/VEP

# ------------------------------
# Output directory for combined MultiQC report
# ------------------------------
MULTIQC_OUT=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/06_Annotate/MultiQC
mkdir -p "$MULTIQC_OUT"

# ------------------------------
# Run MultiQC
# ------------------------------
multiqc "$VEP_DIR" -o "$MULTIQC_OUT"

# ------------------------------
# Record end time
# ------------------------------
date
