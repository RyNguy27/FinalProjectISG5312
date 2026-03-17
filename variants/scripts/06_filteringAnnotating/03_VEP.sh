#!/bin/bash
#SBATCH --job-name=vep
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

hostname
date

# ------------------------------
# Load modules miniconda and activate your VEP environment
module load bcftools/1.16
module load htslib/1.16
module load miniconda3/3.9
source /home/FCAM/rnguyen/miniconda3/bin/activate
conda activate vep_env

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# ------------------------------
# Add your VEP cache directory to environment variables
export PERL5LIB=$CONDA_PREFIX/share/ensembl-vep/modules:$PERL5LIB
VEP_EXEC=$CONDA_PREFIX/bin/vep

# ------------------------------
# Output directory for VEP annotations
OUTDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/06_Annotate/VEP
mkdir -p "$OUTDIR"

# Cache directory for VEP
VEPCACHE=/home/FCAM/rnguyen/.vep

FASTA=$VEPCACHE/homo_sapiens/105_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz

# ------------------------------
# List of filtered VCF sample names
SAMPLES=(SRR20074876 SRR20074878 SRR20074880 SRR20074882 SRR20074884 SRR20074886 SRR20074888 SRR20074890 SRR20074892)

# Directory where your original VCFs live
VCF_DIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/05_variantCalling/gatk

# ------------------------------
# Loop through each sample
for SAMPLE in "${SAMPLES[@]}"
do
    VCF="${VCF_DIR}/${SAMPLE}.mutect2.vcf.gz"
    ANNOTATED_VCF="${OUTDIR}/${SAMPLE}.vep.vcf.gz"
    STATS="${OUTDIR}/${SAMPLE}.vep_summary.html"

    echo "Processing $SAMPLE"

    # Check if VCF exists
    if [ ! -f "$VCF" ]; then
        echo "Error: $VCF not found, skipping..."
        continue
    fi


    # ------------------------------
    # Run VEP annotation safely
    $VEP_EXEC \
      --input_file "$VCF" \
      --output_file "$ANNOTATED_VCF" \
      --vcf \
      --compress_output bgzip \
      --cache \
      --offline \
      --dir_cache "$VEPCACHE" \
      --fasta "$FASTA" \
      --species homo_sapiens \
      --assembly GRCh37 \
      --stats_file "$STATS" \
      --fork 4 \
      --everything   

done

date
