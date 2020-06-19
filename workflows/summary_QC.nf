include MultiQC from '../NextflowModules/MultiQC/1.5/MultiQC.nf' params(optional: "${params.multiqc.optional}", mem: "${params.multiqc.mem}")

workflow summary_QC {
  take:
    qc_files
  main:

    //Run MultiQC
    MultiQC( qc_files )



}
