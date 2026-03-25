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
#SBATCH --array=[0-8]


hostname
date

# make sure partition is specified as `xeon` to prevent slowdowns on amd processors.

# load required software

module load GATK/4.0

# input/output
INDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/03_Alignment/bwa_align
OUTDIR=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/results/05_variantCalling/gatk/test
mkdir -p $OUTDIR


# paired tumor and normal
NORMALS=(SRR20074875 SRR20074877 SRR20074879 SRR20074881 SRR20074883 SRR20074885 SRR20074887 SRR20074889 SRR20074891)
TUMORS=(SRR20074876 SRR20074878 SRR20074880 SRR20074882 SRR20074884 SRR20074886 SRR20074888 SRR20074890 SRR20074892)
N=${NORMALS[$SLURM_ARRAY_TASK_ID]}
T=${TUMORS[$SLURM_ARRAY_TASK_ID]}


# set a variable for the reference genome location
GEN=/home/FCAM/rnguyen/ISG5312/finalprojectISG5312/variants/genome/hs37d5.fa

# sanity check
echo "Tumor BAM: $INDIR/$T.bam"
echo "Normal BAM: $INDIR/$N.bam"
echo "gnomAD: $GNOMAD"

if [ ! -f ${INDIR}/${T}.bam ]; then
    echo "ERROR: Tumor BAM not found: ${INDIR}/${T}.bam"
    exit 1
fi

if [ ! -f ${INDIR}/${N}.bam ]; then
    echo "ERROR: Normal BAM not found: ${INDIR}/${N}.bam"
    exit 1
fi

# ----------------------------
# Step 1: Run Mutect2 (tumor-normal mode)
# ----------------------------
gatk Mutect2 \
    -R ${GEN} \
    -I ${INDIR}/${T}.bam \
    -I ${INDIR}/${N}.bam \
    --tumor ${T} \
    --normal ${N} \
    --max-reads-per-alignment-start 0 \
    --min-base-quality-score 0 \
    --tumor-lod-to-emit 0 \
    --af-of-alleles-not-in-resource 0 \
    -O ${OUTDIR}/${T}.mutect2.raw.vcf.gz

# ----------------------------
# Step 2: Filter raw Mutect2 calls
# ----------------------------
gatk FilterMutectCalls \
    -V ${OUTDIR}/${T}.mutect2.raw.vcf.gz \
    -R ${GEN} \
    -O ${OUTDIR}/${T}.mutect2.vcf.gz

date
