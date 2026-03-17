#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH --mem=8G
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=ryan.j.nguyen@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

# Set locale to avoid Python Click ASCII errors
export LANG=en_US.utf8
export LC_ALL=en_US.utf8
export LANGUAGE=en_US.utf8

INDIR=../../results/03_Alignment/bwa_align/
OUTDIR=../../results/04_alignQC/samstats
MQCDIR=../../results/04_alignQC/samstats/multiqc
mkdir -p $MQCDIR

# run multiQC

module load MultiQC/1.9

# run multiqc on fastqc output
multiqc -f -o $MQCDIR $OUTDIR
