#!/bin/bash
#SBATCH --job-name=Cosmic_GnomAD_VCFdownload
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 12
#SBATCH --mem=15G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ryan.j.nguyen@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

# stop perl warning
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# ----------------------------
# Directories
# ----------------------------
OUTDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/data/resources
mkdir -p ${OUTDIR}

# ----------------------------
# download AF-only gnomAD GRCh37 v2.1.1
# ----------------------------
wget -c -P ${OUTDIR} https://storage.googleapis.com/gcp-public-data--gnomad/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.vcf.bgz
wget -c -P ${OUTDIR} https://storage.googleapis.com/gcp-public-data--gnomad/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.vcf.bgz.tbi

# ----------------------------
# Download COSMIC Genome Screen Mutants VCF (Scripted)
# ----------------------------
# STEP 1: Generate authentication string (run locally, not on HPC)
# echo 'your_email@example.com:your_cosmic_password' | base64
# Replace below with your actual base64 string
# this code is only valid for 1 hour 
COSMIC_AUTH="cnlhbi5qLm5ndXllbkB1Y29ubi5lZHU6TG92ZW1vbmtleTIh"

# STEP 2: Request the JSON from the COSMIC API (returns signed URL)
COSMIC_JSON=$(curl -s -H "Authorization: Basic ${COSMIC_AUTH}" \
"https://cancer.sanger.ac.uk/api/mono/products/v1/downloads/scripted?path=grch37/cosmic/v103/VCF/Cosmic_GenomeScreensMutant_Vcf_v103_GRCh37.tar&bucket=downloads")

# Extract the signed URL from the JSON you already downloaded
COSMIC_SIGNED_URL=$(echo "${COSMIC_JSON}" | grep -oP '(?<="url":")[^"]+')

# Download the actual VCF (gzipped)
wget -c -O ${OUTDIR}/Cosmic_GenomeScreensMutant_Vcf_v103_GRCh37.vcf.gz "${COSMIC_SIGNED_URL}"

date
