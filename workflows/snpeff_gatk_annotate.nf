include SNPEffFilter from '../NextflowModules/snpEff/4.3t/snpEffFilter.nf' params(optional: "${params.snpefffilter.optional}", mem: "${params.snpefffilter.mem}")
include SNPSiftDbnsfp from '../NextflowModules/snpEff/4.3t/SnpSiftDbnsfp.nf' params(optional: "${params.snpsiftsbnsfp.optional}", mem: "${params.snpsiftsbnsfp.mem}", genome_dbnsfp: "${params.genome_dbnsfp}")
include SNPSiftAnnotate from '../NextflowModules/snpEff/4.3t/SnpSiftAnnotate.nf' params(optional: "${params.snpsiftannotate.optional}", mem: "${params.snpsiftannotate.mem}", genome_snpsift_annotate_db: "${params.genome_snpsift_annotate_db}")
include VariantAnnotator from '../NextflowModules/GATK/4.1.3.0/VariantAnnotator.nf' params(mem: "${params.variantannotator.mem}", genome_fasta : "${params.genome_fasta}", genome_variant_annotator_db: "${params.genome_variant_annotator_db}")


workflow snpeff_gatk_annotate {
  take:
    vcfs
  main:
    //Run snpEffFilter annotation step, snpeff should at least be possible
    SNPEffFilter(vcfs)
    // Run snpSift filter step
    if (params.genome_dbnsfp){
        SNPSiftDbnsfp(SNPEffFilter.out)
    }

    //Run GATK Cosmic annotation step
    if(params.genome_variant_annotator_db){
        if (params.genome_dbnsfp){
            VariantAnnotator(SNPSiftDbnsfp.out)
        }else{
            VariantAnnotator(SNPEffFilter.out)
        }
    }

    //Run snpSift GoNL annotation step
    if(params.genome_variant_annotator_db){
        if (params.genome_dbnsfp){
            SNPSiftAnnotate(VariantAnnotator.out)
        }else if (params.genome_dbnsfp){
            SNPSiftAnnotate(SNPSiftDbnsfp.out)        
        }else{
            SNPSiftAnnotate(SNPEffFilter.out)
        }
    }
  emit:
    SNPEffFilter.out
    SNPSiftDbnsfp.out
    VariantAnnotator.out
    SNPSiftAnnotate.out

}
