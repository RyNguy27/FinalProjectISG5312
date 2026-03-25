#!/bin/bash
#SBATCH --job-name=vcf2maf
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=16G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

# ------------------------------
# Load modules and activate VEP environment
module load samtools/1.16.1
module load miniconda3/3.9
source /home/FCAM/rnguyen/miniconda3/bin/activate
conda activate vep_env

# ------------------------------
# Locale settings to avoid Perl warnings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# ------------------------------
# Paths
VCF2MAF=/home/FCAM/rnguyen/tools/vcf2maf/vcf2maf.pl
VEP=/home/FCAM/rnguyen/tools/ensembl-vep-105/ensembl-vep-release-105.0/vep
VEPCACHE=/home/FCAM/rnguyen/.vep
FASTA=$VEPCACHE/homo_sapiens/105_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz

# ------------------------------
# Full Ensembl API paths (added ensembl-io)
export PERL5LIB=/home/FCAM/rnguyen/tools/ensembl-vep-105/ensembl-vep-release-105.0/modules:\
/home/FCAM/rnguyen/tools/ensembl-vep-105/ensembl-vep-release-105.0/modules/Bio:\
/home/FCAM/rnguyen/tools/ensembl-vep-105/ensembl-vep-release-105.0/ensembl_api/ensembl/modules:\
/home/FCAM/rnguyen/tools/ensembl-vep-105/ensembl-vep-release-105.0/ensembl_api/ensembl-variation/modules:\
/home/FCAM/rnguyen/tools/ensembl-vep-105/ensembl-vep-release-105.0/ensembl_api/ensembl-funcgen/modules:\
/home/FCAM/rnguyen/tools/ensembl-vep-105/ensembl-vep-release-105.0/ensembl_api/ensembl-io/modules:$PERL5LIB

export PATH=/home/FCAM/rnguyen/tools/ensembl-vep-105/ensembl-vep-release-105.0/htslib:$PATH

# ------------------------------
# Input/Output directories
VCFDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/05_variantCalling/gatk/test
MAFDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/05_variantCalling/maf/test
mkdir -p "$MAFDIR"

# ------------------------------
# Tumor samples
TUMORS=(SRR20074876 SRR20074878 SRR20074880 SRR20074882 SRR20074884 SRR20074886 SRR20074888 SRR20074890 SRR20074892)

# ------------------------------
# Loop through tumor samples
for T in "${TUMORS[@]}"; do
    VCFGZ=${VCFDIR}/${T}.mutect2.vcf.gz
    VCF=${VCFDIR}/${T}.mutect2.vcf
    MAF=${MAFDIR}/${T}.maf

    echo "-----------------------------"
    echo "Processing tumor: $T"

    # Unzip temporarily
    echo "Unzipping $VCFGZ..."
    gunzip -c "$VCFGZ" > "$VCF"

    # Run vcf2maf using explicit VEP 105 binary
    perl "$VCF2MAF" \
        --input-vcf "$VCF" \
        --output-maf "$MAF" \
        --tumor-id "$T" \
        --vcf-tumor-id "$T" \
        --ref-fasta "$FASTA" \
        --vep-path "$(dirname "$VEP")" \
        --vep-data "$VEPCACHE" \
        --samtools-exec /isg/shared/apps/samtools/1.16.1/bin/samtools \
        --verbose

    # Clean up uncompressed VCF
    echo "Cleaning up $VCF"
    rm "$VCF"

done

echo "All samples processed. Annotated MAFs are in $MAFDIR"
