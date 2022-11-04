include CollectMultipleMetrics from '../NextflowModules/GATK/4.1.3.0/CollectMultipleMetrics.nf' params(optional: "${params.collectmultiplemetrics.optional}", mem: "${params.collectmultiplemetrics.mem}", genome_fasta:"${params.genome_fasta}")
include CollectWGSMetrics from '../NextflowModules/GATK/4.1.3.0/CollectWGSMetrics.nf' params(optional: '', mem: "${params.collectwgsmetrics.mem}", genome_fasta:"${params.genome_fasta}")

workflow postmap_QC {
  take:
    bams
  main:
    run_id = params.out_dir.split('/')[-1]
    //Run CollectMultipleMetrics per sample
    CollectMultipleMetrics(
      bams.map{
        sample_id, bam, bai -> [sample_id, bam]
      }
    )
    // Run WGSMetrics per sample
    CollectWGSMetrics(
      bams.map{
        sample_id, bam, bai -> [sample_id, bam]
      }
    )
    emit:
      CollectWGSMetrics.out
      CollectMultipleMetrics.out
}
