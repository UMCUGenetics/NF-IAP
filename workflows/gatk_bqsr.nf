include { BaseRecalibrationTable } from params.nextflowmodules_path+'/GATK/4.3.0.0/BaseRecalibrationTable.nf' params(mem: "${params.baserecalibrator.mem}", genome_fasta: "${params.genome_fasta}", genome_known_sites: params.genome_known_sites )
include { BaseRecalibration } from params.nextflowmodules_path+'/GATK/4.3.0.0/BaseRecalibration.nf' params(mem: "${params.applybqsr.mem}", genome_fasta: "${params.genome_fasta}")
include { GatherBaseRecalibrationTables } from params.nextflowmodules_path+'/GATK/4.3.0.0/GatherBaseRecalibrationTables.nf' params(mem: "${params.gatherbaserecalibrator.mem}")
include { MergeBams } from params.nextflowmodules_path+'/Sambamba/0.8.2/MergeBams.nf' params(mem: "${params.mergebams.mem}")
include { SplitIntervals } from params.nextflowmodules_path+'/GATK/4.3.0.0/SplitIntervals.nf' params(optional: "${params.splitintervals.optional}")

workflow gatk_bqsr {
  take:
    sample_bams

  main:
    // Create intervals to scatter/gather over
    SplitIntervals( 'no-break', Channel.fromPath( params.genome_interval_list) )

    // Create base recalibration table per interval per sample
    BaseRecalibrationTable( sample_bams.combine(SplitIntervals.out.flatten()) )

    // Merge the base recalibration tables per samples
    GatherBaseRecalibrationTables(BaseRecalibrationTable.out.groupTuple())

    // Apply the base relalibration per interval per sample
    BaseRecalibration(
      sample_bams
        .combine(GatherBaseRecalibrationTables.out, by:0)
        .combine(SplitIntervals.out.flatten())
    )
    // Merge the bam files on a per sample basis
    MergeBams(
      BaseRecalibration.out
        .groupTuple()
        .map{ [it[0],it[2],it[3]] }
    )
  emit:
    MergeBams.out

}
