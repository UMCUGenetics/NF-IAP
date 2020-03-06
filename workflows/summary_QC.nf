include MultiQC from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/MultiQC/1.5/MultiQC.nf' params(params)

workflow summary_QC {
  get:
    qc_files
  main:

    //Run MultiQC
    MultiQC( qc_files )



}
