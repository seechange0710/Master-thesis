process samSortBam{

    publishDir "${params.outdir}/3.Aligment/sBAM/${sample}", mode:'copy'

    input:
    tuple val(sample),path(sam)

    output:
    path("${sample}.sortedP.bam"),emit:sbam

    script:
    """
    mkdir -p "${params.outdir}/3.Aligment/sBAM/${sample}"
    
    samtools sort -@ ${params.cores_nr} \
            ${sam} \
            -O ${params.fmt} \
            -o "${sample}.sortedP.bam"
    """
}


process htseq{

    publishDir "${params.outdir}/4.Quantification/${sample}", mode:'copy'

    input:
    tuple val(sample),path(sbam)
    path(gtf)

    output:
    path("${sample}.count.tsv")

    script:
    """
    mkdir -p "${params.outdir}/4.Quantification/${sample}"

    Python /Users/sichengxu/Documents/Bio_development/htseq/htseq/scripts/htseq-count -m ${params.count_mode} \
            -c "${sample}.count.tsv" \
            -f ${params.fmt} \
            -s ${params.stranded_para} \
            -t ${params.count_type} \
            -i ${params.id_attr} \
            --additional-attr=${params.add_attr} \
            -r ${params.sort_flag} \
            -n ${params.cores_nr} \
            --with-header \
            ${sbam} \
            ${gtf}
    """
}