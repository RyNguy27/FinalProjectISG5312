#!/bin/bash
#SBATCH --job-name=ANNOVAR_dbNSFP_COSMIC
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=16G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

# ------------------------------
# Reproduce study annotation workflow
# Annotate WES variants using ANNOVAR and dbNSFP v1.3
# ------------------------------

hostname
date

# Load modules / set paths
module load anaconda3/2020.02
# Make sure ANNOVAR scripts are in PATH
# e.g., export PATH=/path/to/annovar:$PATH

# ------------------------------
# Input / Output directories
# ------------------------------
INDIR=../../results/05_variantCalling/freebayes/
OUTDIR=../../results/06_Annotate/dbNSFP
mkdir -p ${OUTDIR}

VCF=${INDIR}/freebayes_normAP.vcf.gz

# ------------------------------
# Step 1: Convert VCF to ANNOVAR input
# ------------------------------
convert2annovar.pl ${VCF} -format vcf4 -allsample -withfreq \
  -outfile ${OUTDIR}/freebayes_normAP.avinput

# ------------------------------
# Step 2: Annotate variants using table_annovar.pl
# Protocol includes:
#  - refGene: gene-based annotation
#  - dbNSFP v1.3: functional predictions (SIFT, PolyPhen-2, LRT, MutationTaster, MutationAssessor, phyloP, GERP++)
#  - ClinVar: clinical significance
# ------------------------------
table_annovar.pl ${OUTDIR}/freebayes_normAP.avinput humandb/ \
  -buildver hg38 \
  -out ${OUTDIR}/freebayes_normAP \
  -remove \
  -protocol refGene,dbnsfp35a,clinvar_20210501,cosmic70,cadd13,1000g2015aug_all,esp6500siv2_all,exac03 \
  -operation g,f,f,f,f,f,f,f \
  -nastring . \
  -vcfinput

# ------------------------------
# Step 3: Summarize annotations into final table
# ------------------------------
summarize_annovar.pl ${OUTDIR}/freebayes_normAP.hg38_multianno.txt humandb/ \
  -outfile ${OUTDIR}/freebayes_normAP.summary

# ------------------------------
# Optional: compress and index the VCF output
# ------------------------------
bgzip -c ${OUTDIR}/freebayes_normAP.hg38_multianno.vcf > ${OUTDIR}/freebayes_normAP.annotated.vcf.gz
tabix -p vcf ${OUTDIR}/freebayes_normAP.annotated.vcf.gz

date
