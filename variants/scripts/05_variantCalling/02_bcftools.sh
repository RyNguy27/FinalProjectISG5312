#!/bin/bash 
#SBATCH --job-name=bcftools
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=5G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

module load bcftools/1.16
module load htslib/1.16

# input/output
INDIR=../../results/03_Alignment/bwa_align/
# make output directory if it doesn't exist. 
OUTDIR=../../results/05_variantCalling/bcftools
mkdir -p ${OUTDIR}

# make a list of bam files
ls ${INDIR}/*.bam >${INDIR}/bam_list.txt

# set reference genome location
GEN=../../genome/hs37d5.fa

# call variants
bcftools mpileup -f ${GEN} -b ${INDIR}/bam_list.txt -q 20 -Q 30 | bcftools call -m -v -Oz -o ${OUTDIR}/bcftools.vcf.gz 

# index vcf
tabix -p vcf ${OUTDIR}/bcftools.vcf.gz
