# NF-IAP

Nextflow Illumina Analysis Pipeline. Includes pre/post-mapping QC, BWA mapping & GATK germline calling and variant annotation. The workflow is able to start from multiple entry points (e.g. fastq, bam, gvcf or vcf).

## Installing & Setup

1. [Install Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation)
2. [Install Singularity](https://sylabs.io/guides/3.5/admin-guide/)
2. [Pull NF-IAP](https://github.com/UMCUGenetics/NF-IAP)
3. [Get & configure resources](docs/resources.md)
4. [Configure nextflow](docs/nextflow.md)
5. [Configure processes](docs/processes.md)

## Running the workflow
In this section we'll provide you with a few different ways to run the workflow.

### Change the run-template.config to start your analysis

Always keep these lines in your run.config file:
```
includeConfig 'nextflow.config'
includeConfig 'process.config'
includeConfig 'resources.config'
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

Run the workflow:
```

```





