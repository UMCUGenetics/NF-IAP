# !!Stil under construction!!

# Get & configure resources (per genome)

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

Copy the files in the /Homo_sapiens/Ensembl/GRCh37/Sequence/WholeGenomeFasta/* directory to a resources directory:

```
scp -R /Homo_sapiens/Ensembl/GRCh37/Sequence/WholeGenomeFasta/* /nf-iap/resources/GRCh37/Sequence
```

### 2 Set up GATK bundle
Download the following files from the GATK bundle for your specific build (in this case GRCh37) :
```
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.indels.b37.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/dbsnp_138.b37.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz
```

Unzip all files and copy them to a sensible resources directory. We re-used the directory created in the previous step and copies all files to: /nf-iap/resources/GRCh37/Annotation/
### 3 Set up dbNSFP database
Download the dbNSFP database for your specific build (in this case GRCh37):
```
wget ftp://dbnsfp:dbnsfp@dbnsfp.softgenetics.com/dbNSFPv2.9.3.zip
```
Combine all files and copy the result file to a sensible resources directory. Again we re-used the directory created in step 1 and copied the file to: /nf-iap/resources/GRCh37/Annotation/
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
Copy the gonl.snps_indels.r5.sorted.vcf.gz file to /nf-iap/resources/GRCh37/Annotation/.

### 6 Create genome interval list
If you've download the genome files according to step 1, you can easily create a genome interval list.
```
awk '{ print $1"\t1\t"$2"\t+\t."}' genome.fa.fai | cat genome.dict - > genome.interval_list
```
Copy the  genome.interval_list to /nf-iap/resources/GRCh37/Sequence/.

### 7 Create resources config
Adapt the configs/resources.config file to include the resources you just gathered. An example for human genome build GRCh37 using the files generated in step 1-6:

```
params {
 genomes {
  'GRCh37' {
      fasta = '/nf-iap/resources/GRCh37/Sequence/genome.fa'
      gatk_known_sites = [
       '/nf-iap/resources/GRCh37/Annotation/1000G_phase1.indels.b37.vcf',
       '/nf-iap/resources/GRCh37/Annotation/dbsnp_137.b37.vcf',
       '/nf-iap/resources/GRCh37/Annotation/Mills_and_1000G_gold_standard.indels.b37.vcf'
      ]
      dbsnp = '/nf-iap/resources/GRCh37/Annotation/dbsnp_137.b37.vcf'
      dbnsfp = '/nf-iap/resources/GRCh37/Annotation/dbNSFP2.9.3_variant.txt.gz'
      cosmic = '/nf-iap/resources/GRCh37/Annotation/CosmicCodingMuts_v76.vcf.gz'
      gonl = '/nf-iap/resources/GRCh37/Annotation/gonl.snps_indels.r5.sorted.vcf'
      interval_list = '/nf-iap/resources/GRCh37/Sequence/genome.interval_list'
  }
 }
}

```
