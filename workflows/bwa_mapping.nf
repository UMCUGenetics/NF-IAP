include { BWAMapping } from params.nextflowmodules_path+'/BWA-Mapping/bwa-0.7.17_samtools-1.9/Mapping.nf' params(optional: "${params.bwa.optional}", mem: "${params.bwa.mem}", genome_fasta : "${params.genome_fasta}")
include { Index } from params.nextflowmodules_path+'/BWA/0.7.17/Index.nf' params(optional: "${params.bwaindex.optional}", genome_fasta : "${params.genome_fasta}")
include { Markdup } from params.nextflowmodules_path+'/Sambamba/0.8.2/Markdup.nf' params(optional: "${params.markdup.optional}", mem: "${params.markdup.mem}")
//include { MarkDup as Markdup } from '../NextflowModules/Sambamba/0.6.8/MarkDup.nf' params(optional: "${params.markdup.optional}", mem: "${params.markdup.mem}")

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

    Markdup(BWAMapping.out.groupTuple())
  emit:
    Markdup.out
}
