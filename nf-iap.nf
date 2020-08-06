#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*===========================================================
                        NF-IAP
===========================================================
#### Homepage / Documentation
https://github.com/UMCUGenetics/NF-IAP/tree/develop/docs
----------------------------------------------------------------------------------------
*/
def helpMessage() {
    // Log colors ANSI codes
    c_reset = "\033[0m";
    c_green = "\033[0;32m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";

    log.info"""
    Usage:
      The typical command for running the pipeline is as follows:
      nextflow run nf-iap.nf -c </path/to/run.config> --fastq_path <fastq_dir> --out_dir <output_dir> -profile slurm

      ${c_blue}Mandatory arguments:${c_reset}
       ${c_yellow}--fastq_path, --bam_path, --vcf_path and/or --gvcf_path [str]${c_reset}       Path to a directory containing fastq, bam, vcf or gvcf files.
                                                                           Combinations are possible, but influence availability of analysis steps.
       ${c_yellow}--out_dir [str]${c_reset}                                                     The output directory where results will be saved.
       ${c_yellow}-c [str]${c_reset}                                                            The path to the run.config file. ${c_green}Technically all mandatory and optional arguments can be in the run.config file.${c_reset}
       ${c_yellow}-profile [str]${c_reset}                                                      The preconfigured environment to run on, choose from sge (legacy) or slurm (recommended).
       ${c_yellow}--genome [str]${c_reset}                                                      Choose from the available genomes in resources.config (e.g. GRCh37).

      ${c_blue}Optional workflow arguments:${c_reset}
       ${c_yellow}--premapQC [bool]${c_reset}                                                   Run pre mapping QC. Only runs in combination with --fastq_path. (Default: false)
       ${c_yellow}--postmapQC [bool]${c_reset}                                                  Run post mapping QC. Only runs in combination with --fastq_path, --bam_path. (Default: false)
       ${c_yellow}--germlineCalling [bool]${c_reset}                                            Run GATK germline variant calling. Only runs in combination with --fastq_path, --bam_path or --gvcf_path. (Default: false)
       ${c_yellow}--variantFiltration [bool]${c_reset}                                          Run GATK variant filtration. Only runs in combination with --germlineCalling true or --vcf_path. (Default: false)
       ${c_yellow}--svCalling [bool]${c_reset}                                                  Run SV calling with Manta. Only runs in combination with --fastq_path, --bam_path. (Default: false)
       ${c_yellow}--cnvCalling [bool]${c_reset}                                                 Run CNV calling with Control-FREEC. Only runs in combination with --fastq_path, --bam_path. (Default: false)

      ${c_blue}Optional nextflow arguments:${c_reset}
       ${c_yellow}-resume [str]${c_reset}                                                       Resume a previous nf-iap run.
       ${c_yellow}-N [str]${c_reset}                                                            Send notification to this email when the workflow execution completes.
    """.stripIndent()
}

/*=================================
          Input validation
=================================*/


// Show help message and exit.
if(params.help){
  helpMessage()
  exit 0
}

if ( (!params.fastq_path && !params.bam_path && !params.gvcf_path ) && !params.vcf_path){
  exit 1, "Please provide either a 'fastq_path', 'bam_path', 'gvcf_path' or 'vcf_path'. You can provide these parameters either in the <analysis_name>.config file or on the commandline (add -- in front of the parameter)."
}

if (!params.out_dir){
  exit 1, "No 'out_dir' parameter found in <analysis_name>.config file or on the commandline (add -- in front of the parameter)."
}

if (!params.genome){
  exit 1, "No 'genome' parameter found in in <analysis_name>.config file or on the commandline (add -- in front of the parameter)."
}else{
  if ( !params.genomes[params.genome] || !params.genomes[params.genome].fasta ){
    exit 1, "'genome' parameter ${params.genome} not found in list of genomes in resources.config!"
  }
  if ( !params.genomes[params.genome].interval_list ){
    exit 1, "No interval_list found for ${params.genome}!"
  }
  params.genome_fasta = params.genomes[params.genome].fasta
  params.genome_interval_list = params.genomes[params.genome].interval_list
}

/*=================================
          Run workflow
=================================*/
workflow {
  main :
    def input_fastqs
    def input_bams
    def input_gvcf

    // Gather input FastQ's
    if (params.fastq_path){
      include extractAllFastqFromDir from './NextflowModules/Utils/fastq.nf'
      input_fastqs = extractAllFastqFromDir(params.fastq_path).map{
        sample_id, rg_id, machine, run_nr,fastq_files -> [sample_id, rg_id,fastq_files]
      }
    }
    // Gather input BAM files
    if (params.bam_path){
      include extractBamFromDir from './NextflowModules/Utils/bam.nf'
      input_bams = extractBamFromDir(params.bam_path)
    }
    // Gather input GVCF files
    if (params.gvcf_path) {
      include extractGVCFFromDir from './NextflowModules/Utils/gvcf.nf'
      input_gvcf = extractGVCFFromDir(params.gvcf_path)
    }
    //Gather input VCF files
    if(params.vcf_path) {
      include extractVCFFromDir from './NextflowModules/Utils/vcf.nf'
      input_vcf = extractVCFFromDir(params.vcf_path)
    }

    // Run mapping & premap_QC only when a fastq_path is provided
    if (params.fastq_path){
      include bwa_mapping from './workflows/bwa_mapping.nf' params(params)
      // Optionally run pre mapping QC
      if (params.premapQC) {
        include premap_QC from './workflows/premap_QC.nf' params(params)
        premap_QC(input_fastqs)
      }
      bwa_mapping(input_fastqs)
    }

    // Create a channel containing the bam files from the bwa_mapping step and/or the bam files in bam_path
    if ( params.fastq_path && params.bam_path ){
      input_bams = bwa_mapping.out.mix( input_bams )
    }else if ( params.fastq_path ){
      input_bams = bwa_mapping.out
    }

    // Optionally run post mapping QC
    if (params.postmapQC && input_bams) {
      include postmap_QC from './workflows/postmap_QC.nf' params(params)
      postmap_QC( input_bams )
    }

    // // Depending on whether input_bams and/or input_gvcf were provide start from gatk_bqsr or directly from gatk_germline_calling.
    // // gatk_germline_calling supports both bam and/or gvcf input (one of the channels can be empty)
    if (params.germlineCalling){

      params.genome_known_sites = params.genomes[params.genome].gatk_known_sites
      params.genome_dbsnp = params.genomes[params.genome].dbsnp
      include gatk_bqsr from './workflows/gatk_bqsr.nf' params(params)
      include gatk_germline_calling from './workflows/gatk_germline_calling.nf' params(params)

      if (input_bams && input_gvcf){
        gatk_bqsr( input_bams )
        gatk_germline_calling(gatk_bqsr.out, input_gvcf )
      }else if(input_bams){
        gatk_bqsr( input_bams )
        gatk_germline_calling(gatk_bqsr.out, Channel.empty() )
      }else if(input_gvcf){
        gatk_germline_calling(Channel.empty(), input_gvcf)
      }
    }


    //Run variant filtration on generated vcfs or input vcfs
    if (params.variantFiltration){
      include gatk_variantfiltration from './workflows/gatk_variantfiltration.nf' params(params)
      if( gatk_germline_calling.out ){
        gatk_variantfiltration(gatk_germline_calling.out[0])
      }else if (input_vcf){
        gatk_variantfiltration(
          input_vcf.map{
            id, vcf, idx -> [id, 'NA', vcf, idx, 'NA']
          }
        )
      }
    }

    //Run variant annotation on filtered vcfs or input vcfs
    if (params.variantAnnotation){
      params.genome_dbnsfp = params.genomes[params.genome].dbnsfp
      params.genome_variant_annotator_db = params.genomes[params.genome].cosmic
      params.genome_snpsift_annotate_db = params.genomes[params.genome].gonl
      include snpeff_gatk_annotate from './workflows/snpeff_gatk_annotate.nf' params(params)

      if (gatk_variantfiltration.out){
        snpeff_gatk_annotate(gatk_variantfiltration.out)
      }else if(input_vcf){
        snpeff_gatk_annotate(input_vcf)
      }
    }
    //Test code
    // if (params.splitVCF && !params.vcf_path){
    //   if (input_bams && input_gvcf){
    //     input_bams.mix(input_gvcf).map{
    //       sample_id, file,idx -> sample_id
    //     }
    //     .unique()
    //     .view()
    //   }else if(input_bams){
    //     input_bams.map{
    //       sample_id, file,idx -> sample_id
    //     }
    //     .view()
    //   }else if(input_gvcf){
    //     input_gvcf.map{
    //       sample_id, file,idx -> sample_id
    //     }
    //     .view()
    //   }
    // }


    // Run summary_QC only when both pre- and post-mapping QC are finished.
    if (params.premapQC && params.postmapQC && input_fastqs && input_bams){
      include summary_QC from './workflows/summary_QC.nf' params(params)
      summary_QC( premap_QC.out
        .mix(postmap_QC.out[0]).collect()
        .mix(postmap_QC.out[1]).collect()
      )
    }else if (params.premapQC && input_fastqs){
      include summary_QC from './workflows/summary_QC.nf' params(params)
      summary_QC(premap_QC.out.collect())
    }else if (params.postmapQC  && input_bams){
      include summary_QC from './workflows/summary_QC.nf' params(params)
      summary_QC(postmap_QC.out[0].collect())
    }

    // Run sv calling only when either bam-files or fastq files were provided as input and svCalling is true
    if (params.svCalling && input_bams ){
      include sv_calling from './workflows/sv_calling.nf' params(params)
      sv_calling(input_bams)
    }

    // Run cnv calling only when either bam-files or fastq files were provided as input and cnvCalling is true
    if (params.cnvCalling && input_bams){
      params.genome_freec_chr_len = params.genomes[params.genome].freec_chr_len
      params.genome_freec_chr_files = params.genomes[params.genome].freec_chr_files
      params.genome_freec_mappability = params.genomes[params.genome].freec_mappability
      include cnv_calling from './workflows/cnv_calling.nf' params(params)
      cnv_calling(input_bams)
    }
}
