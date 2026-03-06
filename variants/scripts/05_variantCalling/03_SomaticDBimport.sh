#!/bin/bash
#SBATCH --job-name=DBimportSomatic
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 12
#SBATCH --mem=15G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

# stop perl warning
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

module load htslib/1.16
module load perl/5.32.1

# ----------------------------
# Directories
# ----------------------------
ANNOVAR_DIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/data/resources
HDB=${ANNOVAR_DIR}/humandb
mkdir -p ${HDB}
mkdir -p ${ANNOVAR_DIR}

# ----------------------------
# 0) Download ANNOVAR
# ----------------------------
echo ">>> Download ANNOVAR"
if [ ! -f "${ANNOVAR_DIR}/annovar/annotate_variation.pl" ]; then
    wget -c http://www.openbioinformatics.org/annovar/download/0wgxR2rIVP/annovar.latest.tar.gz -O ${ANNOVAR_DIR}/annovar.latest.tar.gz
    tar -xzf ${ANNOVAR_DIR}/annovar.latest.tar.gz -C ${ANNOVAR_DIR}/
else
    echo "ANNOVAR already downloaded."
fi
ANNOVAR_BIN=${ANNOVAR_DIR}/annovar/annotate_variation.pl

# ----------------------------
# 0) RefGene (gene annotation)
# ----------------------------
echo ">>> Download RefGene"
if [ ! -f "${HDB}/hg19_refGene.txt" ]; then
    ${ANNOVAR_BIN} -buildver hg19 -downdb refGene ${HDB} -webfrom annovar
else
    echo "RefGene already exists."
fi

# ----------------------------
# 1) dbNSFP v3.0 -v1.3 isn't available anymore
# ----------------------------
echo ">>> Download dbNSFP v3.0a"
if [ ! -f "${HDB}/dbnsfp30a.txt.gz" ]; then
    # ANNOVAR officially supports downloading it via -downdb
    ${ANNOVAR_BIN} -buildver hg19 -downdb dbnsfp30a ${HDB} -webfrom annovar
else
    echo "dbNSFP v3.0a already exists."
fi

# ----------------------------
# 2) ClinVar
# ----------------------------
echo ">>> Download ClinVar"
if [ ! -f "${HDB}/clinvar.vcf.gz" ]; then
    wget -c https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar.vcf.gz -P ${HDB}
    wget -c https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar.vcf.gz.tbi -P ${HDB}
else
    echo "ClinVar already exists."
fi

# ----------------------------
# 4) 1000 Genomes
# ----------------------------
echo ">>> Download 1000 Genomes"
perl ${ANNOVAR_BIN} -buildver hg19 -downdb 1000g2015aug ${HDB} -webfrom annovar

# ----------------------------
# 5) ESP6500
# ----------------------------
echo ">>> Download ESP6500"
perl ${ANNOVAR_BIN} -buildver hg19 -downdb esp6500siv2_all ${HDB} -webfrom annovar

# ----------------------------
# 6) ExAC
# ----------------------------
echo ">>> Download ExAC"
if [ ! -f "${HDB}/ExAC.r1.sites.vep.vcf.gz" ]; then
    wget -c -P ${HDB} https://storage.googleapis.com/gcp-public-data--gnomad/legacy/exac_browser/ExAC.r1.sites.vep.vcf.gz
    wget -c -P ${HDB} https://storage.googleapis.com/gcp-public-data--gnomad/legacy/exac_browser/ExAC.r1.sites.vep.vcf.gz.tbi
else
    echo "ExAC already exists."
fi

# ----------------------------
# 7) CADD
# ----------------------------
echo ">>> Download CADD v1.7 full SNV table"
if [ ! -f "${HDB}/cadd13.tsv.gz" ]; then
    # Use the US mirror (replace with DE if you prefer)
    CADD_FILE="whole_genome_SNVs_inclAnno.tsv.gz"
    wget -c -P ${HDB} https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh37/${CADD_FILE}
    wget -c -P ${HDB} https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh37/${CADD_FILE}.tbi
    
    # Rename to ANNOVAR standard
    mv ${HDB}/${CADD_FILE} ${HDB}/cadd13.tsv.gz
    mv ${HDB}/${CADD_FILE}.tbi ${HDB}/cadd13.tsv.gz.tbi
else
    echo "CADD already exists."
fi

# ----------------------------
# 8) exome gnomAD GRCh37 v2.1.1
# ----------------------------
wget -c -P ${ANNOVAR_DIR} https://storage.googleapis.com/gcp-public-data--gnomad/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.vcf.bgz
wget -c -P ${ANNOVAR_DIR} https://storage.googleapis.com/gcp-public-data--gnomad/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.vcf.bgz.tbi

# ----------------------------
# 9) COSMIC Genome Screen Mutants VCF
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
wget -c -O ${ANNOVAR_DIR}/Cosmic_GenomeScreensMutant_Vcf_v103_GRCh37.vcf.gz "${COSMIC_SIGNED_URL}"

# Extract and index COSMIC
cd ${HDB}
tar -xvf Cosmic_GenomeScreensMutant_Vcf_v103_GRCh37.vcf.gz
mv Cosmic_GenomeScreensMutant_Vcf_v103_GRCh37.vcf.gz cosmic103.vcf.gz
bgzip -f cosmic103.vcf.gz
tabix -p vcf cosmic103.vcf.gz

echo ">>> All databases downloaded and indexed for ANNOVAR."

date

