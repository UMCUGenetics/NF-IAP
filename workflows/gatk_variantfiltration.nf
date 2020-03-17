include SelectVariants from '../NextflowModules/GATK/4.1.3.0/SelectVariants.nf' params(params)
include VariantFiltration from '../NextflowModules/GATK/4.1.3.0/VariantFiltration.nf' params(params)
include MergeVCFs as MergeVCF from '../NextflowModules/GATK/4.1.3.0/MergeVCFs.nf' params(params)

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
