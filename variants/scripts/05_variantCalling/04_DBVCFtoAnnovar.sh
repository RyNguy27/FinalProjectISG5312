#!/bin/bash
#SBATCH --job-name=DBimportAllDBs
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=40G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL_HERE
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

# ----------------------------
# Environment
# ----------------------------
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

module load perl/5.32.1
module load htslib/1.16

# ----------------------------
# Directories and ANNOVAR binaries
# ----------------------------
HDB=/scratch/rnguyen/resources/annovar/humandb
ANNOVAR_BIN=/scratch/rnguyen/resources/annovar

# ----------------------------
# Convert ClinVar VCF
# ----------------------------
CLINVAR_VCF=${HDB}/clinvar.vcf.gz
CLINVAR_TXT=${HDB}/hg19_clinvar.txt

echo ">>> Converting ClinVar VCF to ANNOVAR format..."
${ANNOVAR_BIN}/convert2annovar.pl -format vcf4 ${CLINVAR_VCF} -outfile ${CLINVAR_TXT}

if [ -f "${CLINVAR_TXT}" ]; then
    echo ">>> ClinVar conversion successful!"
    ls -lh ${CLINVAR_TXT}
else
    echo "!!! ERROR: ${CLINVAR_TXT} was not created!"
fi

# ----------------------------
# Convert COSMIC VCF
# ----------------------------
COSMIC_VCF=${HDB}/Cosmic_GenomeScreensMutant_v103_GRCh37.vcf.gz
COSMIC_TXT=${HDB}/hg19_Cosmic.txt

echo ">>> Converting COSMIC VCF to ANNOVAR format..."
${ANNOVAR_BIN}/convert2annovar.pl -format vcf4 ${COSMIC_VCF} -outfile ${COSMIC_TXT}

if [ -f "${COSMIC_TXT}" ]; then
    echo ">>> COSMIC conversion successful!"
    ls -lh ${COSMIC_TXT}
else
    echo "!!! ERROR: ${COSMIC_TXT} was not created!"
fi

# ----------------------------
# Convert gnomAD exomes VCF
# ----------------------------
GNOMAD_VCF=${HDB}/gnomad.exomes.r2.1.1.sites.vcf.bgz
GNOMAD_TXT=${HDB}/hg19_gnomad_exome.txt

echo ">>> Converting gnomAD exomes VCF to ANNOVAR format..."
${ANNOVAR_BIN}/convert2annovar.pl -format vcf4 -outfile ${GNOMAD_TXT} ${GNOMAD_VCF}

if [ -f "${GNOMAD_TXT}" ]; then
    echo ">>> gnomAD conversion successful!"
    ls -lh ${GNOMAD_TXT}
else
    echo "!!! ERROR: ${GNOMAD_TXT} was not created!"
fi

# ------------------------------
# Step 1: Decompress BGZF VCF to plain VCF
# ------------------------------
echo "Decompressing gnomAD VCF..."
bcftools view gnomad.exomes.r2.1.1.sites.vcf.bgz -Ov -o gnomad.exomes.r2.1.1.sites.vcf

# ------------------------------
# Step 2: Convert plain VCF to ANNOVAR txt
# ------------------------------
echo "Converting to ANNOVAR format..."
perl ${ANNOVAR}/convert2annovar.pl \
    -format vcf4 \
    -allsample \
    -withfreq \
    gnomad.exomes.r2.1.1.sites.vcf \
    -outfile hg19_gnomad211_exome.txt

tabix -s 1 -b 2 -e 3 hg19_gnomad211_exome.txt

date