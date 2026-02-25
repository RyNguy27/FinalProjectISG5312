#!/bin/bash 
#SBATCH --job-name=download_genome
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=10G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err


hostname
date


OUTDIR=../../genome
mkdir -p $OUTDIR
cd $OUTDIR

# this is downloading the whole reference genome verision GRCh37

wget https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/GRCh37/hs37d5.fa.gz
gunzip *gz
