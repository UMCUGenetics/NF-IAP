include { MarkdownToHtml } from '../NextflowModules/Pandocker/21.02/MarkdownToHtml.nf' params( params )
include { MarkdownToPdf } from '../NextflowModules/Pandocker/21.02/MarkdownToPdf.nf' params( params )
include { FillMdTemplate } from '../utils/FillMdTemplate.nf' params( params )    

workflow generate_report {
    take:
        report_name
        md_template

    main:
        FillMdTemplate( report_name, md_template )
        report_md_file = FillMdTemplate.out.md_file

        MarkdownToHtml( report_md_file )
        MarkdownToPdf( report_md_file )
      
    emit:
        html_report =  MarkdownToHtml.out
        pdf_report =  MarkdownToPdf.out
        md_report = report_md_file
}
