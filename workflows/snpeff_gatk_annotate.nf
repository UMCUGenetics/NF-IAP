include snpEffFilter from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/snpEff/4.3t/snpEffFilter.nf' params(params)
include SnpSiftDbnsfp from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/snpEff/4.3t/SnpSiftDbnsfp.nf' params(params)
include SnpSiftAnnotate from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/snpEff/4.3t/SnpSiftAnnotate.nf' params(params)
include VariantAnnotator from '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/GATK/4.1.3.0/VariantAnnotator.nf' params(params)


workflow snpeff_gatk_annotate {
  get:
    vcfs
  main:
    //Run snpEffFilter annotation step
    snpEffFilter(vcfs)

    // Run snpSift filter step
    SnpSiftDbnsfp(snpEffFilter.out)

    //Run GATK Cosmic annotation step
    VariantAnnotator(SnpSiftDbnsfp.out)

    //Run snpSift GoNL annotation step
    SnpSiftAnnotate(VariantAnnotator.out)

  emit:
    SnpSiftAnnotate.out

}
