include Manta from '../NextflowModules/Manta/1.6.0/Manta.nf' params(optional:'', mem: "${params.manta.mem}", genome_fasta : "${params.genome_fasta}")

workflow sv_calling {
  take :
    sample_bams
  main:
    Manta(sample_bams)
  emit:
    Manta.out
}
