include HaplotypeCaller from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/GATK/4.1.3.0/HaplotypeCaller.nf' params(params)
include CombineGVCFs from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/GATK/4.1.3.0/CombineGVCFs.nf' params(params)
include MergeVCFs as MergeGVCF from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/GATK/4.1.3.0/MergeVCFs.nf' params(params)
include GenotypeGVCFs from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/GATK/4.1.3.0/GenotypeGVCFs.nf' params(params)
include SplitIntervals from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/GATK/4.1.3.0/SplitIntervals.nf' params(params)

workflow gatk_germline_calling {
  get:
    sample_bams
    sample_gvcfs
  main:
    run_id = params.out_dir.split('/')[-1]

    /* Create intervals to scatter/gather over */
    SplitIntervals( 'break', Channel.fromPath(params.scatter_interval_list) )

    /* Run haplotype calling per sample per interval*/
    HaplotypeCaller( sample_bams.combine(SplitIntervals.out.flatten()))

    if (sample_gvcfs){
        sample_gvcfs_channel = sample_gvcfs.combine(SplitIntervals.out.flatten()).map{
          sample_id, gvcf, tbi, interval_file ->
          def interval = interval_file.toRealPath().toString().split("/")[-2]
          [sample_id, interval, gvcf, tbi, interval_file]
        }
        gvcf_combine_per_interval = HaplotypeCaller.out
          .mix(sample_gvcfs_channel)
          .groupTuple(by:[1])
          .map{
            sample_ids, interval, gvcfs, idxs, interval_files ->
            [run_id, interval, gvcfs, idxs, interval_files[0]]
          }
    }else{
      gvcf_combine_per_interval = HaplotypeCaller.out
        .groupTuple(by:[1])
        .map{
          sample_ids, interval, gvcfs, idxs, interval_files ->
          [run_id, interval, gvcfs, idxs, interval_files[0]]
        }
    }

    /* Combine GVCFs per interval */
    CombineGVCFs(
      gvcf_combine_per_interval
    )

    /* Merge GVCFs per sample for storage */
    MergeGVCF(
      HaplotypeCaller.out.groupTuple(by:[0]).map{
        sample_id, intervals, gvcfs, idxs, interval_files ->
        [sample_id, gvcfs, idxs]
      }
    )

    /* Genotype GVCFs per interval */
    GenotypeGVCFs(CombineGVCFs.out)
  emit:
    GenotypeGVCFs.out
    MergeGVCF.out
}
