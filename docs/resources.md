# Get & configure resources (per genome)

## Steps

1. [Reference genome](#1-set-up-reference-genome)
2. [GATK bundle (human only)](#2-set-up-gatk-bundle)
3. [dbNSFP database (human only)](#3-set-up-dbnsfp-database)
4. [Cosmic database (human only)](#4-set-up-cosmic-database)
5. [GoNL database (human only)](#5-set-up-gonl-database)
6. [Create genome interval list](#6-create-genome-interval-list)
7. [Create FREEC resource files (human only)](#7-create-freec-resource-files)
8. [Create resources config](#8-create-resources-config)


### 1 Set up reference genome
Download your reference genome of choice from:
https://support.illumina.com/sequencing/sequencing_software/igenome.html

```
wget http://igenomes.illumina.com.s3-website-us-east-1.amazonaws.com/Homo_sapiens/Ensembl/GRCh37/Homo_sapiens_Ensembl_GRCh37.tar.gz
tar -xzvf Homo_sapiens_Ensembl_GRCh37.tar.gz
```

Copy the files in the /Homo_sapiens/Ensembl/GRCh37/Sequence/WholeGenomeFasta/* directory to a resources directory:

```
cp -R /Homo_sapiens/Ensembl/GRCh37/Sequence/WholeGenomeFasta/* /nf-iap/resources/GRCh37/Sequence
```

### 2 Set up GATK bundle
Download the following files from the GATK bundle for your specific build (in this case GRCh37) :
```
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.indels.b37.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.indels.b37.vcf.idx.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/dbsnp_138.b37.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/dbsnp_138.b37.vcf.idx.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.idx.gz
```

Copy them to a sensible resources directory. We re-used the directory created in the previous step and copies all files to: /nf-iap/resources/GRCh37/Annotation/. Now unzip all the files and re-zip + index them using the following commands:
```
gunzip <filename>.vcf.gz
bgzip <filename>.vcf   
tabix <filename>.vcf.gz
```

### 3 Set up dbNSFP database
Download the dbNSFP database for your specific build (in this case GRCh37):
```
wget ftp://dbnsfp:dbnsfp@dbnsfp.softgenetics.com/dbNSFPv2.9.3.zip
unzip dbNSFPv2.9.3.zip
```
Combine all files and copy the result file to a sensible resources directory. Again we re-used the directory created in step 1 and copied the file to: /nf-iap/resources/GRCh37/Annotation/
```
(head -n 1 dbNSFP2.9.3_variant.chr1 ; cat dbNSFP2.9.3_variant.chr* | grep -v "^#" ) > dbNSFP2.9.3.txt
bgzip dbNSFP2.9.3.txt
tabix -s 1 -b 2 -e 2 dbNSFP2.9.3.txt.gz
```


### 4 Set up COSMIC database
TODO

### 5 Set up GoNL database
Download all snp_indels files from https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/.
Combine all .vcf.gz files together and sort them, we used picard for this (https://gatk.broadinstitute.org/hc/en-us).

```
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr1.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr2.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr3.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr4.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr5.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr6.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr7.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr8.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr9.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr10.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr11.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr12.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr13.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr14.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr15.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr16.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr17.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr18.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr19.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr20.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr21.snps_indels.r5.vcf.gz;
wget https://molgenis26.target.rug.nl/downloads/gonl_public/variants/release5/gonl.chr22.snps_indels.r5.vcf.gz;

java -Xmx4g -jar picard.jar -Djava.io.tmpdir=`pwd`/tmp SortVcf \
      I=gonl.chr1.snps_indels.r5.vcf.gz \
      I=gonl.chr2.snps_indels.r5.vcf.gz \
      I=etc.vcf
      O=gonl.snps_indels.r5.sorted.vcf
      TMP_DIR=`pwd`/tmp
gzip gonl.snps_indels.r5.sorted.vcf
```
Copy the gonl.snps_indels.r5.sorted.vcf.gz file to /nf-iap/resources/GRCh37/Annotation/.

### 6 Create genome interval list
If you've download the genome files according to step 1, you can easily create a genome interval list.
```
awk '{ print $1"\t1\t"$2"\t+\t."}' genome.fa.fai | cat genome.dict - > genome.interval_list
```
Copy the  genome.interval_list to /nf-iap/resources/GRCh37/Sequence/.

### 7 Create FREEC resource files


Create (or download) a genome.len file. For GRCh37 one is available at http://bioinfo-out.curie.fr/projects/freec/src/hg19.len.
```
wget http://bioinfo-out.curie.fr/projects/freec/src/hg19.len
```

Create a directory containing a .fa (fasta) file per chromosome. You can split up the original genome.fa. The human genome the chr_files directory looks like this:
```
chr_files
      chr1.fa
      chr10.fa
      chr11.fa
      etc
```
Download and unzip the freec_mappability file.
```
wget https://xfer.curie.fr/get/nil/7hZIk1C63h0/hg19_len100bp.tar.gz
tar -xzvf https://xfer.curie.fr/get/nil/7hZIk1C63h0/hg19_len100bp.tar.gz
```



### 8 Create resources config
Adapt the configs/resources.config file to include the resources you just gathered. Also don't forget to set the resource_dir. An example for human genome build GRCh37 using the files generated in step 1-6:

```
params {
 resource_dir = '/full/path/to/resources/dir/'
  genomes {
    "GRCh37" {
      fasta = "${params.resource_dir}/GRCh37/Sequence/genome.fa"
      gatk_known_sites = [
        "${params.resource_dir}/GRCh37/Annotation/1000G_phase1.indels.b37.vcf",
        "${params.resource_dir}/GRCh37/Annotation/dbsnp_137.b37.vcf",
        "${params.resource_dir}/GRCh37/Annotation/Mills_and_1000G_gold_standard.indels.b37.vcf"
      ]
      dbsnp = "${params.resource_dir}/GRCh37/Annotation/dbsnp_137.b37.vcf"
      dbnsfp = "${params.resource_dir}/GRCh37/Annotation/dbNSFP2.9.3_variant.txt.gz"
      cosmic = "${params.resource_dir}/GRCh37/Annotation/CosmicCodingMuts_v76.vcf.gz"
      gonl = "${params.resource_dir}/GRCh37/Annotation/gonl.snps_indels.r5.sorted.vcf"
      interval_list = "${params.resource_dir}/GRCh37/Sequence/genome.interval_list"
      freec_chr_len = "${params.resource_dir}/GRCh37/Sequence/genome.len"
      freec_chr_files = "${params.resource_dir}/GRCh37/Sequence/chr_files"
      freec_mappability = "${params.resource_dir}/GRCh37/Annotation/misc/out100m2_hg19.gem"
    }
  }
}

```
