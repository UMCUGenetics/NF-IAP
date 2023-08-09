include { SelectVariants } from params.nextflowmodules_path+'/GATK/4.3.0.0/SelectVariants.nf' params(optional: '',mem: "${params.selectvariants.mem}", genome_fasta: "${params.genome_fasta}", compress: "${params.compress}")
include { VariantFiltration } from params.nextflowmodules_path+'/GATK/4.3.0.0/VariantFiltration.nf' params(optional: '', mem: "${params.variantfiltration.mem}", 
                                                                                                           genome_fasta: "${params.genome_fasta}", 
                                                                                                           gatk_snp_filter: "${params.gatk_snp_filter}", 
                                                                                                           gatk_indel_filter: "${params.gatk_indel_filter}", 
                                                                                                           gatk_rna_filter: "${params.gatk_rna_filter}",
                                                                                                           compress: "${params.compress}")
include { MergeVCFs as MergeVCF } from params.nextflowmodules_path+'/GATK/4.3.0.0/MergeVCFs.nf' params(optional: '',mem: "${params.mergevcf.mem}", compress: "${params.compress}")

workflow gatk_variantfiltration {
  take:
    vcfs
  main:
    // Select SNPs and INDELs for variant filtration per interval
    SelectVariants(
      vcfs
        .map{
          run_id, interval, vcf, idx, interval_file ->
          [run_id, interval, vcf, idx]
        }
        .combine(['SNP', 'INDEL'])
    )

    // Perform variant filtration for SNPs and INDELs per interval
    VariantFiltration(SelectVariants.out)

    // Merge genotyped vcf files
    MergeVCF(
      VariantFiltration.out.groupTuple().map{
        run_id, intervals, types,vcfs, idxs ->
        [run_id, vcfs, idxs ]
      }
    )
  emit:
    MergeVCF.out

}
