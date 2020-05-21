# NF-IAP

Nextflow Illumina Analysis Pipeline. Includes pre/post-mapping QC, BWA mapping & GATK germline calling and variant annotation. The workflow is able to start from multiple entry points (e.g. fastq, bam, gvcf or vcf).

## Installing & Setup

1. [Install Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation)
2. [Install Singularity](https://sylabs.io/guides/3.5/admin-guide/)
3. [Pull/Clone NF-IAP](#pull-or-clone)
4. [Get & configure resources](docs/resources.md)
5. [Configure nextflow](docs/nextflow.md)
6. [Configure processes](docs/processes.md)

## Pull or Clone 
Be sure to add the --recursive option to also included the neccessary modules.

```
git clone git@github.com:UMCUGenetics/NF-IAP.git --recursive
```

## Running the workflow
In this section we'll provide you with a few different ways to run the workflow.

### Change the run-template.config to start your analysis

Always keep these lines in your run.config file:
```
includeConfig '/path/to/config/nextflow.config'
includeConfig '/path/to/config/process.config'
includeConfig '/path/to/config/resources.config'
```
All of the parameters in the params section can also be supplied on the commandline or can be pre-filled in the run.config file.
```
params {
  fastq_path = ''
  bam_path = ''
  vcf_path = ''
  gvcf_path = ''
  out_dir = ''
  genome = 'GRCh37'

  premapQC = true
  postmapQC = true
  germlineCalling = true
  variantFiltration = true
  variantAnnotation = true
}

```
### Starting the full workflow from fastq files
Create the run.config file to look like this:
```
params {
  fastq_path = '/path/to/fastqfiles/'
  bam_path = ''
  vcf_path = ''
  gvcf_path = ''
  out_dir = ''
  genome = 'GRCh37'

  premapQC = true
  postmapQC = true
  germlineCalling = true
  variantFiltration = true
  variantAnnotation = true
}
```

Run the workflow on sge :
```
nextflow run nf-iap.nf -c run.config --out_dir /processed_data/runX/ -profile sge -resume
```

### Starting the full workflow from from a combination of fastq, bam and gvcf files
Create the run.config file to look like this:
```
params {
  fastq_path = '/path/to/fastqfiles/'
  bam_path = '/path/to/bamfiles/'
  vcf_path = ''
  gvcf_path = '/path/to/gvcffiles/'
  out_dir = ''
  genome = 'GRCh37'

  premapQC = true
  postmapQC = true
  germlineCalling = true
  variantFiltration = true
  variantAnnotation = true
}
```
Run the workflow on slurm :
```
nextflow run nf-iap.nf -c run.config --out_dir /processed_data/runX/ -profile slurm -resume
```

### Starting only the variant annotation on one or more vcf files (can't be combined with fastq's,bam's or gvcf's).
```
params {
  fastq_path = ''
  bam_path = ''
  vcf_path = '/path/to/vcffiles/'
  gvcf_path = ''
  out_dir = ''
  genome = 'GRCh37'

  premapQC = false
  postmapQC = false
  germlineCalling = false
  variantFiltration = false
  variantAnnotation = true
}
```
Run the workflow on slurm :
```
nextflow run nf-iap.nf -c run.config --out_dir /processed_data/runX/ -profile slurm -resume
```
