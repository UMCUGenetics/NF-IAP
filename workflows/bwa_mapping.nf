include BWAMapping from '../NextflowModules/BWA-Mapping/bwa-0.7.17_samtools-1.9/Mapping.nf' params(optional: "${params.bwa.optional}", mem: "${params.bwa.mem}", genome_fasta : "${params.genome_fasta}")
include Index from '../NextflowModules/BWA/0.7.17/Index.nf' params(optional: "${params.bwaindex.optional}", genome_fasta : "${params.genome_fasta}")
include MarkDup from '../NextflowModules/Sambamba/0.6.8/MarkDup.nf' params(optional: "${params.markdup.optional}", mem: "${params.markdup.mem}")

workflow bwa_mapping {
  take:
    fastqs
  main:
    //Index the reference genome, if needed
    Index(Channel.value(file(params.genome_fasta)))
    fastqs.combine(Index.out).map{
      it ->
      [it[0],it[1],it[2]]
    } | BWAMapping

    MarkDup(BWAMapping.out.groupTuple())
  emit:
    MarkDup.out
}
