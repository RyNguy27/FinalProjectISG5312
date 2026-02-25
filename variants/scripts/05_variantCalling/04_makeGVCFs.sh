#!/bin/bash 
#SBATCH --job-name=gatk_gvcf
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 7
#SBATCH --mem=20G
#SBATCH --qos=general
#SBATCH --partition=xeon
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%A_%a.out
#SBATCH -e %x_%A_%a.err
#SBATCH --array=[0-9]


hostname
date

# make sure partition is specified as `xeon` to prevent slowdowns on amd processors. 

# load required software

module load GATK/4.0

# input/output
INDIR=../../results/03_Alignment/bwa_align/

OUTDIR=../../results/05_variantCalling/gatk
mkdir -p $OUTDIR

# choose a sample for array task
ACCLIST=../../metadata/accessionlist.txt
SAMPLELIST=($(cat $ACCLIST))
SAMPLE=${SAMPLELIST[$SLURM_ARRAY_TASK_ID]}

# set a variable for the reference genome location
GEN=../../genome/hs37d5.fa

# run haplotype caller on one sample
# ----------------------------
# Step 1: Run Mutect2 (tumor-only)
# ----------------------------
gatk Mutect2 \
    -R ${GEN} \
    -I ${INDIR}/${SAMPLE}.bam \
    --tumor ${SAMPLE} \
    --cosmic ${COSMIC} \
    --germline-resource ${GNOMAD} \
    -O ${OUTDIR}/${SAMPLE}.mutect2.raw.vcf.gz

# ----------------------------
# Step 2: Filter raw Mutect2 calls
# ----------------------------
gatk FilterMutectCalls \
    -V ${OUTDIR}/${SAMPLE}.mutect2.raw.vcf.gz \
    -R ${GEN} \
    -O ${OUTDIR}/${SAMPLE}.mutect2.vcf.gz

date
