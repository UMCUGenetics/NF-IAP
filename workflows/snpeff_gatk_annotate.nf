include { SNPEffFilter } from params.nextflowmodules_path+'/snpEff/5.1d/snpEffFilter.nf' params(optional: "${params.snpefffilter.optional}", mem: "${params.snpefffilter.mem}", snpeff_datadir: "${params.snpeff_datadir}", snpeff_genome: "${params.snpeff_genome}")
include { SNPSiftDbnsfp } from params.nextflowmodules_path+'/snpEff/5.1d/SnpSiftDbnsfp.nf' params(optional: "${params.snpsiftsbnsfp.optional}", mem: "${params.snpsiftsbnsfp.mem}", genome_dbnsfp: "${params.genome_dbnsfp}")
include { SNPSiftAnnotate } from params.nextflowmodules_path+'/snpEff/5.1d/SnpSiftAnnotate.nf' params(optional: "${params.snpsiftannotate.optional}", mem: "${params.snpsiftannotate.mem}", genome_snpsift_annotate_db: "${params.genome_snpsift_annotate_db}")
include { VariantAnnotator } from params.nextflowmodules_path+'/GATK/4.3.0.0/VariantAnnotator.nf' params(mem: "${params.variantannotator.mem}", genome_fasta : "${params.genome_fasta}", genome_variant_annotator_db: "${params.genome_variant_annotator_db}")
include { Tabix_BgzipTabix as BgzipTabixSnpEffFilter } from params.nextflowmodules_path+'/Tabix/1.11/BgzipTabix.nf' params(mem: "${params.tabix.mem}")
include { Tabix_BgzipTabix as BgzipTabixSnpSiftDbnsfp } from params.nextflowmodules_path+'/Tabix/1.11/BgzipTabix.nf' params(mem: "${params.tabix.mem}")
include { Tabix_BgzipTabix as BgzipTabixSnpSiftAnnotate } from params.nextflowmodules_path+'/Tabix/1.11/BgzipTabix.nf' params(mem: "${params.tabix.mem}")

workflow snpeff_gatk_annotate {
  take:
    vcfs

  main:
    annotated_vcf = Channel.empty()
    //Run snpEffFilter annotation step, snpeff should at least be possible, replace with VEP
    SNPEffFilter(vcfs)

    //def runid = "RUNID_TEMPLATE"
    //dirty way, still as DataFlowVariable
    //def runid = SNPEffFilter.out.collect().first()
    
    //def runid2 = SNPEffFilter.out.flatten().first()
    //def runid = SNPEffFilter.out.map{ it[0] }.toString()
    //runid2.view()
    //def runid = ""+runid2
    
    def runid = SNPEffFilter.out.flatten().first()
    
  
    BgzipTabixSnpEffFilter(SNPEffFilter.out.map{it -> it[1]})
    //annotated_vcf = BgzipTabixSnpEffFilter.out.map { vcf, vcf_index -> [SNPEffFilter.out.map{it -> it[0]}, vcf, vcf_index]}
    annotated_vcf = BgzipTabixSnpEffFilter.out.map { vcf, vcf_index -> [runid, vcf, vcf_index]}

    // Run snpSift filter step
    if (params.genome_dbnsfp){
        SNPSiftDbnsfp(annotated_vcf)
        BgzipTabixSnpSiftDbnsfp(SNPSiftDbnsfp.out.map{it -> it[1]})
        //annotated_vcf = BgzipTabixSnpSiftDbnsfp.out.map { vcf, vcf_index -> [SNPSiftDbnsfp.out.map{it -> it[0]}, vcf, vcf_index]}
        annotated_vcf = BgzipTabixSnpSiftDbnsfp.out.map { vcf, vcf_index -> [runid, vcf, vcf_index]}
    //    annotated_vcf = SNPSiftDbnsfp.out
    }

    //Run snpSift GoNL annotation step
    if(params.genome_snpsift_annotate_db){
        SNPSiftAnnotate(annotated_vcf)
        BgzipTabixSnpSiftAnnotate(SNPSiftAnnotate.out.map{it -> it[1]})
        //annotated_vcf = BgzipTabixSnpSiftAnnotate.out.map { vcf, vcf_index -> [SNPSiftAnnotate.out.map{it -> it[0]}, vcf, vcf_index]}
        annotated_vcf = BgzipTabixSnpSiftAnnotate.out.map { vcf, vcf_index -> [runid, vcf, vcf_index]}
//        annotated_vcf = SNPSiftAnnotate.out
    }

    //Run GATK Cosmic annotation step
    if(params.genome_variant_annotator_db){
        VariantAnnotator(annotated_vcf)
        annotated_vcf = VariantAnnotator.out
    }
    
  emit:
    annotated_vcf

}
