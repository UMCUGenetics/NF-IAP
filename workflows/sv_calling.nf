include RunWorkflow from '../NextflowModules/Manta/1.6.0/RunWorkflow.nf' params(optional:'', mem: "${params.manta.mem}", genome_fasta : "${params.genome_fasta}", manta_path: "/hpc/local/CentOS7/cog_bioinf/manta-1.6.0/bin")

workflow sv_calling {
  take :
    sample_bams
  main:
    RunWorkflow(sample_bams)
  emit:
    RunWorkflow.out
}
