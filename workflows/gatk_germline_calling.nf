include { HaplotypeCaller } from params.nextflowmodules_path+'/GATK/4.3.0.0/HaplotypeCaller.nf' params(optional:"${params.haplotypecaller.optional}", mem: "${params.haplotypecaller.mem}", genome_fasta : "${params.genome_fasta}", compress: "${params.compress}")
include { CombineGVCFs } from params.nextflowmodules_path+'/GATK/4.3.0.0/CombineGVCFs.nf' params(mem: "${params.combinegvcfs.mem}", genome_fasta: "${params.genome_fasta}", compress: "${params.compress}")
include { MergeVCFs as MergeGVCF } from params.nextflowmodules_path+'/GATK/4.3.0.0/MergeVCFs.nf' params(mem: "${params.mergevcf.mem}", compress: "${params.compress}")
include { GenotypeGVCFs } from params.nextflowmodules_path+'/GATK/4.3.0.0/GenotypeGVCFs.nf' params(mem: "${params.genotypegvcfs.mem}", genome_fasta: "${params.genome_fasta}", genome_dbsnp: "${params.genome_dbsnp}", compress: "${params.compress}")
include { SplitIntervals } from params.nextflowmodules_path+'/GATK/4.3.0.0/SplitIntervals.nf' params(optional: "${params.splitintervals.optional}", mem: "${params.splitintervals.mem}")

workflow gatk_germline_calling {
  take:
    sample_bams
    sample_gvcfs

  main:
    run_id = params.out_dir.split('/')[-1]

    // Create intervals to scatter/gather over
    SplitIntervals( 'break', Channel.fromPath(params.genome_interval_list) )

    //Channel for GVCF per bam file (for storage)
    bam_gvcfs = Channel.empty()

    if (sample_bams ){
      // Run haplotype calling per sample per interval
      HaplotypeCaller( sample_bams.combine(SplitIntervals.out.flatten()))

      // Merge only the new GVCFs per sample for storage
      MergeGVCF(
        HaplotypeCaller.out.groupTuple(by:[0]).map{
          sample_id, intervals, gvcfs, idxs, interval_files ->
          [sample_id, gvcfs, idxs]
        }
      )
      bam_gvcfs = MergeGVCF.out
    }

    //Channel for genotyped gvcfs
    genotype_gvcfs = Channel.empty()

    if (!params.generateGvcfsOnly){
        //Set up Channel for gvcf per interval from input gvcfs
        sample_gvcfs_channel = Channel.empty()
        if (sample_gvcfs){
            sample_gvcfs_channel = sample_gvcfs.combine(SplitIntervals.out.flatten()).map{
                sample_id, gvcf, tbi, interval_file ->
                def interval = interval_file.toRealPath().toString().split("/")[-2]
                [sample_id, interval, gvcf, tbi, interval_file]
              }
        }

        //Set up Channel for gvcf per interval generated from input bams
        sample_bams_channel = Channel.empty()
        if (sample_bams ){
          sample_bams_channel = HaplotypeCaller.out
        }

        //Mix them
        gvcf_per_interval = sample_bams_channel
            .mix(sample_gvcfs_channel)
            .groupTuple(by:[1])
            .map{
              sample_ids, interval, gvcfs, idxs, interval_files ->
              [run_id, interval, gvcfs, idxs, interval_files[0]]
            }
        
        //Combine GVCFs per interval (all samples per interval)
        CombineGVCFs(
          gvcf_per_interval
        )

        // Genotype GVCFs per interval
        GenotypeGVCFs(CombineGVCFs.out)
        genotype_gvcfs = GenotypeGVCFs.out
    }
  emit:
    genotype_gvcfs
    bam_gvcfs
}
