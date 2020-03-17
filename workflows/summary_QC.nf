include MultiQC from '../NextflowModules/MultiQC/1.5/MultiQC.nf' params(params)

workflow summary_QC {
  take:
    qc_files
  main:

    //Run MultiQC
    MultiQC( qc_files )



}
