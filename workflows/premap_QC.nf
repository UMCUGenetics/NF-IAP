include FastQC from '../NextflowModules/FastQC/0.11.5/FastQC' params(optional : '--noextract', mem: "${params.fastqc.mem}")

workflow premap_QC {
  take:
    fastqs
  main:
    //Run fastqc on a per sample per lane basis
    FastQC(fastqs)
  emit:
    FastQC.out
}
