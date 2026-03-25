#!/bin/bash
#SBATCH --job-name=annovar_dbNSFP
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date
export LC_ALL=C

module load perl/5.32.1
module load htslib/1.16
module load bcftools/1.16

ANNOVAR=/scratch/rnguyen/resources/annovar
HDB=/scratch/rnguyen/resources/annovar/humandb
INDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/05_variantCalling/gatk/test
OUTDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/06_Annotate/dbNSFP/test
mkdir -p ${OUTDIR}

# Ensure ANNOVAR database symlinks
ln -sf ${HDB}/hg19_Cosmic.txt ${HDB}/Cosmic

ln -sf ${HDB}/hg19_dbnsfp30a.txt ${HDB}/dbnsfp30a.txt
ln -sf ${HDB}/hg19_dbnsfp30a.txt.idx ${HDB}/dbnsfp30a.txt.idx

ln -sf ${HDB}/hg19_clinvar.txt ${HDB}/hg19_clinvar_20210501.txt
ln -sf ${HDB}/hg19_clinvar.txt.idx ${HDB}/hg19_clinvar_20210501.txt.idx

ln -sf ${HDB}/hg19_ALL.sites.2015_08.txt ${HDB}/hg19_1000g2015aug_all.txt
ln -sf ${HDB}/hg19_ALL.sites.2015_08.txt.idx ${HDB}/hg19_1000g2015aug_all.txt.idx


for VCF in ${INDIR}/*.mutect2.vcf.gz
do
    SAMPLE=$(basename ${VCF} .mutect2.vcf.gz)
    echo "Processing sample: ${SAMPLE}"
# Convert VCF to ANNOVAR input (multi-sample compatible)
    AVINPUT=${OUTDIR}/${SAMPLE}.avinput
    ${ANNOVAR}/convert2annovar.pl \
        -format vcf4 \
        -allsample \
        -withfreq \
        -includeinfo \
        -outfile ${AVINPUT} \
        ${VCF}

    if [ ! -s ${AVINPUT} ]; then
        echo "WARNING: ${SAMPLE}.avinput is empty, skipping annotation."
        continue
    fi

    # Annotate variants with table_annovar.pl
    ${ANNOVAR}/table_annovar.pl \
        ${AVINPUT} ${HDB} \
        -buildver hg19 \
        -out ${OUTDIR}/${SAMPLE} \
        -remove \
        -protocol refGene,dbnsfp30a,clinvar_20210501,Cosmic,1000g2015aug_all,esp6500siv2_all \
        -operation g,f,f,f,f,f \
        -nastring . \
        -otherinfo

done

date
