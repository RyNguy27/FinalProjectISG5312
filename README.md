# Somatic Variant Calling Workflow

## Overview
This repository contains the scripts and results for the somatic variant calling workflow. Data used in this workflow is stored under NCBI BioProject PRJNA857496 and contains tumor-normal samples for 9 patients with gastric cancer (GC). The aim of this repository is to detect genes that contribute to increased risk of gastric cancer development by identifying somatic single nucleotide variants (SNVs) and insertion/deletions (indels) in tumor samples and comparing them to the variants seen in their respective normal (germline) samples.

## Original Study Citation 
Nurgalieva, A., Galliamova, L., Ekomasova, N., Yankina, M., Sakaeva, D., Valiev, R., Prokofyeva, D., Dzhaubermezov, M., Fedorova, Y., Khusnutdinov, S., & Khusnutdinova, E. (2023). Whole Exome Sequencing Study Suggests an Impact of FANCA, CDH1 and VEGFA Genes on Diffuse Gastric Cancer Development. Genes, 14(2), 280. https://doi.org/10.3390/genes14020280

## Data Description
BioProject: PRJNA857496
SRA Study: SRP385802
Platform: Illumina Paired-end sequencing 
Data size: Bytes: 32.97 Gb; Bases: 50.92 G
Total number of samples: 18 

## Workflow Outline

### Step 1: Data Download
- Download Raw FASTQ files from NCBI SRA and reference genome GRCh37  

### Step 2: Raw Read QC
- FastQC with MultiQC on raw reads
- Trimmomatic for adapter and quality trimming
- FastQC with MultiQC on trimmed reads 

### Step 3: Indexing & Alignment
- BWA-MEM index
- BWA-MEM alignment

### Step 4: Alignment QC
- Samtools Stats with MultiQC
- Coverage check QC
- Bedtoolsnuc QC

### Step 5: Variant Calling
- Freebayes 
- bcftools
- Create VCF
 - GATK Mutect2 (tumor sample)
 - GATK Haplotypecaller (normal sample)

### Step 6: Filtering & Annotating 
- Filter variants based on quality metrics
- Normalize Variants
- Annotate using:
 - dbNSFP and COSMIC 
 - bcftoolsCSQ
 - SnpEff for summary 

## Repository Structure
```
FinalProjectISG5312/
| README.md
| variants/
|-- data/
|-- metadata/
|-- genome/
|-- results/
|  |-- 02_qc/
|  |  |-- fastqc_raw/
|  |  |-- trimmed_fastq/
|  |  `-- fastqc_trimmed/
|  |-- 03_align/
|  |  |-- bwa_index/
|  |  `-- bwa_align/
|  |-- 04_alignQC/
|  |  |-- samtools/
|  |  |-- coverage/
|  |  `-- bedtoolsnuc/
|  |-- 05_variantCalling/
|  |  |-- freebayes/
|  |  |-- bcftools/
|  |  |-- gatk/
|  |  `-- isec_output/
|  `-- 06_annotation/
|     |-- bcftoolsCSQ/
|     |-- dbNSFP/
|     `-- snpEff/
|-- scripts/
|  |-- 01_downloadData/
|  |-- 02_qc/
|  |-- 03_align/
|  |-- 04_alignQC/
|  |-- 05_variantCalling/
|  `-- 06_annotation/
```

## Software Versions
- sratoolkit/3.0.1
- fastqc/0.11.7
- Trimmomatic/0.39
- samtools/1.16.1
- bedtools/2.29.0
- bamtools/2.5.1
- freebayes/1.3.4
- htslib/1.16
- htslib/1.7
- bcftools/1.16
- picard/2.23.9
- GATK/4.0
- vcflib/1.0.0-rc1
- snpEff/4.3q
- anaconda3/2020.02
