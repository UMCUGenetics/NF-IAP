include { FastQC } from params.nextflowmodules_path+'/FastQC/0.11.9/FastQC' params(optional : "${params.fastqc.optional}", mem: "${params.fastqc.mem}")

workflow premap_QC {
  take:
    fastqs
  main:
    //Run fastqc on a per sample per lane basis
    FastQC(fastqs)
  emit:
    FastQC.out
}
