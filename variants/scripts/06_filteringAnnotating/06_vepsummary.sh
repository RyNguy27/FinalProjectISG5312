#!/bin/bash
#SBATCH --job-name=vep_damaging_filter
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=16G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err



############################
# LOAD MODULES (edit for your cluster)
############################

module load bcftools/1.16

############################
# INPUT / OUTPUT
############################

INPUT_DIR="/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/06_Annotate/VEP"
OUTPUT_DIR="${INPUT_DIR}/lof_results"
mkdir -p "${OUTPUT_DIR}"

COHORT_FILE="${OUTPUT_DIR}/COHORT_LOF.tsv"
RECUR_FILE="${OUTPUT_DIR}/GENE_RECURRENCE.txt"

echo -e "Sample\tCHROM\tPOS\tREF\tALT\tGene\tConsequence" > "${COHORT_FILE}"

FILTER="stop_gained|frameshift_variant|splice_acceptor_variant|splice_donor_variant|start_lost|stop_lost"

############################
# LOOP OVER VEP FILES
############################

for vcf in "${INPUT_DIR}"/*.vep.vcf.gz; do

    sample=$(basename "${vcf}" .vep.vcf.gz)

    echo "Processing ${sample}"

    bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/CSQ\n' "${vcf}" | \
    awk -F'\t' -v sample="${sample}" -v OFS="\t" -v filter="${FILTER}" '
    {
        if ($5 ~ filter) {

            n = split($5, arr, ",");

            for (i = 1; i <= n; i++) {

                if (arr[i] ~ filter) {

                    split(arr[i], f, "|");

                    gene = f[4];
                    consequence = f[2];

                    if (gene != "" && consequence != "") {
                        print sample, $1, $2, $3, $4, gene, consequence;
                    }
                }
            }
        }
    }' >> "${COHORT_FILE}"

done

############################
# GENE RECURRENCE
############################

echo "Building gene recurrence table..."

tail -n +2 "${COHORT_FILE}" | cut -f6 | \
sort | uniq -c | sort -nr > "${RECUR_FILE}"

echo "DONE"
