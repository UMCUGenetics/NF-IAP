include { MultiQC } from params.nextflowmodules_path+'/MultiQC/1.14/MultiQC.nf' params(optional: "${params.multiqc.optional}", mem: "${params.multiqc.mem}")

workflow summary_QC {
  take:
    run_name
    qc_files
  main:

    //Run MultiQC
    MultiQC( run_name, qc_files )



}
