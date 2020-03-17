# Get & configure resources

## Steps

1. [Reference genome](#1-set-up-reference-genome)
2. [GATK bundle](#2-set-up-gatk-bundle)
3. [dbNSFP database (human only)](#3-set-up-dbnsfp-database)
4. [Cosmic database (human only)](#4-set-up-cosmic-database)
5. [GoNL database (human only)](#5-set-up-gonl-database)
6. [Create genome interval list](#6-create-genome-interval-list)
7. [Create resources config](#7-create-resources-config)


### 1 Set up reference genome

### 2 Set up GATK bundle

### 3 Set up dbNSFP database

### 4 Set up COSMIC database

### 5 Set up GoNL database

### 6 Create genome interval list

### 7 Create resources config

```
params {

  genome_fasta = '/hpc/cog_bioinf/GENOMES/Homo_sapiens.GRCh37.GATK.illumina/Homo_sapiens.GRCh37.GATK.illumina.fasta'
  genome_known_sites = ['/hpc/cog_bioinf/common_dbs/GATK_bundle/1000G_phase1.indels.b37.vcf',
  '/hpc/cog_bioinf/common_dbs/GATK_bundle/dbsnp_137.b37.vcf',
  '/hpc/cog_bioinf/common_dbs/GATK_bundle/Mills_and_1000G_gold_standard.indels.b37.vcf']
  genome_dbsnp = '/hpc/cog_bioinf/common_dbs/GATK_bundle/dbsnp_137.b37.vcf'
  genome_dbnsfp = '/hpc/cog_bioinf/common_dbs/dbNSFP/dbNSFPv2.9/dbNSFP2.9.txt.gz'
  genome_variant_annotator_db = '/hpc/cog_bioinf/common_dbs/cosmic/CosmicCodingMuts_v76.vcf.gz'
  genome_snpsift_annotate_db = '/hpc/cog_bioinf/common_dbs/GoNL/gonl_release5/site_freqs/gonl.snps_indels.r5.sorted.vcf.gz'
  genome_interval_list = '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/resources/Homo_sapiens.GRCh37.GATK.illumina.chromosomes.interval_list'
  
}

```
