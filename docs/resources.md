# Get & configure resources

## Steps

1. [Reference genome](#1-set-up-reference-genome)
2. [GATK bundle (human only)](#2-set-up-gatk-bundle)
3. [dbNSFP database (human only)](#3-set-up-dbnsfp-database)
4. [Cosmic database (human only)](#4-set-up-cosmic-database)
5. [GoNL database (human only)](#5-set-up-gonl-database)
6. [Create genome interval list](#6-create-genome-interval-list)
7. [Create resources config](#7-create-resources-config)


### 1 Set up reference genome
Download your reference genome of choice from:
https://support.illumina.com/sequencing/sequencing_software/igenome.html

```
wget http://igenomes.illumina.com.s3-website-us-east-1.amazonaws.com/Homo_sapiens/Ensembl/GRCh37/Homo_sapiens_Ensembl_GRCh37.tar.gz
tar -xzvf Homo_sapiens_Ensembl_GRCh37.tar.gz
```

Copy the resulting directory to a chosen resources directory.

```
scp -R Homo_sapiens /nf-iap/resources
```

### 2 Set up GATK bundle
Download the following files from the GATK bundle for your specific build (in this case GRCh37) :
```
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.indels.b37.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/dbsnp_138.b37.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz
```

Unzip all files and copy them to a sensible resources directory. We re-used the directory created in the previous step and copies all files to: /nf-iap/resources/Homo_sapiens/Ensembl/GRCh37/Annotation/
### 3 Set up dbNSFP database
Download the dbNSFP database for your specific build (in this case GRCh37):
```
wget ftp://dbnsfp:dbnsfp@dbnsfp.softgenetics.com/dbNSFPv2.9.3.zip
```
Combine all files and copy the result file to a sensible resources directory. Again we re-used the directory created in step 1 and copied the file to: /nf-iap/resources/Homo_sapiens/Ensembl/GRCh37/Annotation/
```
cat dbNSFP2.9.3_variant.chr* | grep -v "^#" | cat header.txt - | gzip > dbNSFP2.9.3_variant.txt.gz
```


### 4 Set up COSMIC database
TODO

### 5 Set up GoNL database
Download all snp_indels files from https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/.
Combine all .vcf.gz files together and sort them, we used picard for this (https://gatk.broadinstitute.org/hc/en-us).

```
java -jar picard.jar SortVcf \
      I=gonl.chr1.snps_indels.r5.vcf.gz \
      I=gonl.chr2.snps_indels.r5.vcf.gz \
      I=etc.vcf
      O=gonl.snps_indels.r5.sorted.vcf
gzip gonl.snps_indels.r5.sorted.vcf
```

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
