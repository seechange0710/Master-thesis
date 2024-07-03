process hisat2_idx{

    //publishDir "${params.indir}/DB/index_dir", mode: 'copy', pattern:"*.ht2"

    input:
    path(genome)

    output:
    path("${params.species}.*.ht2"),emit:index

    script: //mkdir -p ${params.indir}/DB/index_dir
    """

    hisat2-build -f $genome \
                 "${params.species}"

    """

}

process hisat2_ali{

    publishDir "${params.outdir}/3.Aligment/SAM/${sample}", mode: 'copy'

    input:
    tuple val(sample),path(reads)
    path indexDir

    output:
    path("${sample}.sam"),emit:sam
    path("${sample}_summary.txt")


    script:
    """
    mkdir -p "${params.outdir}/3.Aligment/SAM/${sample}"
    
    hisat2 -p ${params.cores_nr} \
           -x ${params.species} \
           -1 ${reads[0]} \
           -2 ${reads[1]} \
           -S ${sample}.sam \
           --summary-file ${sample}_summary.txt \
    
    """
}