include ControlFreec from '../NextflowModules/Control-FREEC/v11.5/ControlFreec.nf' params(optional: "ploidy=2\nwindow=1000\ntelocentromeric=50000\nBedGraphOutput=TRUE\n",mem: "${params.controlfreec.mem}",freec_path:'/hpc/local/CentOS7/cog_bioinf/freec_v11.0',sambamba_path:'/hpc/local/CentOS7/cog_bioinf/sambamba_v0.7.0/sambamba',samtools_path:'/hpc/local/CentOS7/cog_bioinf/samtools-1.9/samtools',genome_freec_chr_len: "${params.genome_freec_chr_len}",genome_freec_chr_files: "${params.genome_freec_chr_files}",genome_freec_mappability: "${params.genome_freec_mappability}")

workflow cnv_calling {
  take :
    sample_bams
  main:
    ControlFreec(sample_bams)
  emit:
    ControlFreec.out
}
