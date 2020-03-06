include FastQC from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/FastQC/0.11.5/FastQC.nf' params(params)

workflow premap_QC {
  get:
    fastqs
  main:
    //Run fastqc on a per sample per lane basis
    FastQC(fastqs)
  emit:
    FastQC.out
}
