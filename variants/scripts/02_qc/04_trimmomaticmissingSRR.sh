#!/bin/bash
#SBATCH --job-name=trimmomatic
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=15G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@uconn.edu
#SBATCH -o %x_%A_%a.out
#SBATCH -e %x_%A_%a.err


hostname
date

#################################################################
# Trimmomatic
#################################################################

module load Trimmomatic/0.39
module load parallel/20180122

# set input/output directory variables
INDIR=../../data/fastq
TRIMDIR=../../results/02_qc/trimmed_fastq
mkdir -p $TRIMDIR

# adapters to trim out
ADAPTERS=/isg/shared/apps/Trimmomatic/0.39/adapters/TruSeq3-PE-2.fa


# run trimmomatic

java -jar $Trimmomatic PE -threads 4 \
        ${INDIR}/SRR20074883_1.fastq.gz \
        ${INDIR}/SRR20074883_2.fastq.gz \
        ${TRIMDIR}/SRR20074883_trim.1.fq.gz ${TRIMDIR}/SRR20074883_trim_orphans.1.fq.gz \
        ${TRIMDIR}/SRR20074883_trim.2.fq.gz ${TRIMDIR}/SRR20074883_trim_orphans.2.fq.gz \
        ILLUMINACLIP:"${ADAPTERS}":2:30:10 \
        SLIDINGWINDOW:4:15 MINLEN:45
