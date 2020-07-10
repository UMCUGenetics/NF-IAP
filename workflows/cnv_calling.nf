include Freec from '../NextflowModules/ControlFREEC/11.5/Freec.nf' params(
  mem: "${params.freec.mem}",
  chr_len_file: "${params.genome_freec_chr_len}",
  chr_files: "${params.genome_freec_chr_files}",
  gem_mappability_file: "${params.genome_freec_mappability}",
  ploidy: "${params.freec_ploidy}",
  window : "${params.freec_window}",
  telocentromeric : "${params.freec_telocentromeric}"
)
include AssessSignificance from '../NextflowModules/ControlFREEC/11.5/AssessSignificance.nf' params()
include MakeGraph from '../NextflowModules/ControlFREEC/11.5/MakeGraph.nf' params(ploidy: "${params.freec_ploidy}")
include MakeKaryotype from '../NextflowModules/ControlFREEC/11.5/MakeKaryotype.nf' params(ploidy: "${params.freec_ploidy}",telocentromeric : "${params.freec_telocentromeric}", maxlevel: "${params.freec_maxlevel}")


workflow cnv_calling {
  take :
    sample_bams
  main:
    Freec(sample_bams)
    AssessSignificance(Freec.out.cnv)
    MakeGraph(Freec.out.cnv)
    MakeKaryotype(Freec.out.cnv)

  emit:
    Freec.out.cnv
    Freec.out.other
    AssessSignificance.out
    MakeGraph.out
    MakeKaryotype.out
}
