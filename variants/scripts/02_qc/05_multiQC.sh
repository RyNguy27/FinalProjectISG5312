#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 2
#SBATCH --mem=10G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ryan.j.nguyen@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

export LANG=en_US.utf8
export LC_ALL=en_US.utf8


#################################################################
# Aggregate reports using MultiQC
#################################################################

module load MultiQC/1.9

INDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/02_qc/fastqc_trimmed
OUTDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/02_qc/fastqc_trimmed/multiqc
mkdir -p  $OUTDIR

# run on fastqc output
multiqc -f -o ${OUTDIR} ${INDIR}
