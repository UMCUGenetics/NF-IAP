#!/usr/bin/env nextflow

nextflow.preview.dsl=2

include '/hpc/cog_bioinf/cuppen/personal_data/sander/scripts/Nextflow/NextflowModules/Utils/utils.nf'
include premap_QC from './workflows/premap_QC.nf' params(params)
include postmap_QC from './workflows/postmap_QC.nf' params(params)
include bwa_mapping from './workflows/bwa_mapping.nf' params(params)
include gatk_bqsr from './workflows/gatk_bqsr.nf' params(params)
include gatk_germline_calling from './workflows/gatk_germline_calling.nf' params(params)
include gatk_variantfiltration from './workflows/gatk_variantfiltration.nf' params(params)
include snpeff_gatk_annotate from './workflows/snpeff_gatk_annotate.nf' params(params)

/*  Check if all necessary input parameters are present (yes still very rudimentary)*/
if (!params.fastq_path && !params.bam_path && !params.gvcf_path){
  exit 1, "Please provide either a fastq_path, bam_path or gvcf_path!"
}

if (!params.out_dir){
  exit 1, "No 'out_dir' parameter found in config file!"
}


workflow {
  main :
    def input_fastqs
    def input_bams
    def input_gvcf

    if (params.fastq_path){
      // Gather input FastQ's
      input_fastqs = extractFastqFromDir(params.fastq_path)
    }

    if (params.bam_path){
      // Gather input BAM files
      input_bams = extractBamFromDir(params.bam_path)
    }

    if (params.gvcf_path) {
      // Gather input GVCF files
      input_gvcf = extractGVCFFromDir(params.gvcf_path)
    }

    if (params.fastq_path){
      premap_QC(input_fastqs)
      bwa_mapping(input_fastqs)
    }

    if ( bwa_mapping.out && params.bam_path ){
      postmap_QC( bwa_mapping.out.mix( input_bams ))
      gatk_bqsr( bwa_mapping.out.mix(input_bams) )
    }else if ( bwa_mapping.out ){
      postmap_QC( bwa_mapping.out )
      gatk_bqsr( bwa_mapping.out )
    }else{
      gatk_bqsr( input_bams )
      postmap_QC( input_bams )
    }

    if ( gatk_bqsr.out && input_gvcf){
      gatk_germline_calling(gatk_bqsr.out, input_gvcf )
    }else{
      gatk_germline_calling(gatk_bqsr.out, Channel.empty() )
    }

    gatk_variantfiltration(gatk_germline_calling.out[0])

    snpeff_gatk_annotate(gatk_variantfiltration.out)
}
