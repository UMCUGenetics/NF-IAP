include HaplotypeCaller from '../NextflowModules/GATK/4.1.3.0/HaplotypeCaller.nf' params(optional:"${params.haplotypecaller.optional}", mem: "${params.haplotypecaller.mem}", genome_fasta : "${params.genome_fasta}")
include CombineGVCFs from '../NextflowModules/GATK/4.1.3.0/CombineGVCFs.nf' params(mem: "${params.combinegvcfs.mem}", genome_fasta: "${params.genome_fasta}")
include MergeVCFs as MergeGVCF from '../NextflowModules/GATK/4.1.3.0/MergeVCFs.nf' params(mem: "${params.mergevcf.mem}")
include GenotypeGVCFs from '../NextflowModules/GATK/4.1.3.0/GenotypeGVCFs.nf' params(mem: "${params.genotypegvcfs.mem}", genome_fasta: "${params.genome_fasta}", genome_dbsnp: "${params.genome_dbsnp}")
include SplitIntervals from '../NextflowModules/GATK/4.1.3.0/SplitIntervals.nf' params(optional: "${params.splitintervals.optional}")

workflow gatk_germline_calling {
  take:
    sample_bams
    sample_gvcfs
  main:
    run_id = params.out_dir.split('/')[-1]

    // Create intervals to scatter/gather over
    SplitIntervals( 'break', Channel.fromPath(params.genome_interval_list) )


    if (sample_gvcfs && sample_bams){
      // Run haplotype calling per sample per interval
      HaplotypeCaller( sample_bams.combine(SplitIntervals.out.flatten()))

      // Scatter existing GVCFs over intervals
      sample_gvcfs_channel = sample_gvcfs.combine(SplitIntervals.out.flatten()).map{
        sample_id, gvcf, tbi, interval_file ->
        def interval = interval_file.toRealPath().toString().split("/")[-2]
        [sample_id, interval, gvcf, tbi, interval_file]
      }
      // Mix in existing GVCF files
      gvcf_per_interval = HaplotypeCaller.out
        .mix(sample_gvcfs_channel)
        .groupTuple(by:[1])
        .map{
          sample_ids, interval, gvcfs, idxs, interval_files ->
          [run_id, interval, gvcfs, idxs, interval_files[0]]
        }
      // Merge only the new GVCFs per sample for storage
      MergeGVCF(
        HaplotypeCaller.out.groupTuple(by:[0]).map{
          sample_id, intervals, gvcfs, idxs, interval_files ->
          [sample_id, gvcfs, idxs]
        }
      )
    }else if (sample_bams){
      // Run haplotype calling per sample per interval
      HaplotypeCaller( sample_bams.combine(SplitIntervals.out.flatten()))
      gvcf_per_interval = HaplotypeCaller.out
        .groupTuple(by:[1])
        .map{
          sample_ids, interval, gvcfs, idxs, interval_files ->
          [run_id, interval, gvcfs, idxs, interval_files[0]]
        }

      //Merge GVCFs per sample for storage
      MergeGVCF(
        HaplotypeCaller.out.groupTuple(by:[0]).map{
          sample_id, intervals, gvcfs, idxs, interval_files ->
          [sample_id, gvcfs, idxs]
        }
      )
    }else if (sample_gvcfs){
      // Scatter existing GVCFs over intervals
      gvcf_per_interval = sample_gvcfs.combine(SplitIntervals.out.flatten()).map{
        sample_id, gvcf, tbi, interval_file ->
        def interval = interval_file.toRealPath().toString().split("/")[-2]
        [sample_id, interval, gvcf, tbi, interval_file]
      }
    }

    //Combine GVCFs per interval (all samples per interval)
    CombineGVCFs(
      gvcf_per_interval
    )

    // Genotype GVCFs per interval
    GenotypeGVCFs(CombineGVCFs.out)
  emit:
    GenotypeGVCFs.out
    MergeGVCF.out
}
