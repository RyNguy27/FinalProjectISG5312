#!/bin/bash
#SBATCH --job-name=bcftoolsCSQ
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

module load htslib/1.7
module load bcftools/1.20

# make a directory if it doesn't exist
INDIR=../../results/05_variantCalling/freebayes/
OUTDIR=../../results/06_Annotate/bcftoolsCSQ
mkdir -p ${OUTDIR}

GENOME=../../genome/hs37d5.fa
VCFIN=${INDIR}/mutect2_filtered.vcf.gz
VCFOUT=${OUTDIR}/mutect2_annotated_csq.vcf.gz

# Using release 75 (last GRCh37 Ensembl release)
# FTP: ftp://ftp.ensembl.org/pub/grch37/release-75/gff3/homo_sapiens/
GFFURL=ftp://ftp.ensembl.org/pub/grch37/release-75/gff3/homo_sapiens/Homo_sapiens.GRCh37.75.gff3.gz
GFF=${OUTDIR}/Homo_sapiens.GRCh37.75.gff3

if [ ! -f ${GFF} ]; then
    wget -P ${OUTDIR} ${GFFURL}
    gunzip -f ${GFF}
fi


# fix up chromosome 20 names
sed -i 's/^/chr/' ${OUTDIR}/Homo_sapiens.GRCh37.75.gff3.gz

GFF=${OUTDIR}/Homo_sapiens.GRCh37.75.gff3.gz

# -------------------------
# Run bcftools csq annotation
# -------------------------
bcftools csq \
    --phase a \
    -f ${GENOME} \
    -g ${GFF} \
    ${VCFIN} \
    -Oz -o ${VCFOUT}

# Index output VCF
tabix -p vcf ${VCFOUT}

date
