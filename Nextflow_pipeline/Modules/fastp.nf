process fastp {

    publishDir "${params.outdir}/2.Trimming/Qtrim/${sample}", mode: 'copy'

    input:
    tuple val(sample),path(reads)

    output:
    tuple val("${sample}"),path("${sample}_*_Qtrimmed.fq.gz"),emit: qtrim // Q-trimmed read 1 & 2
    path("${sample}_Qtrimmed_summary.html") // html summary

    script:
    """
    mkdir -p "${params.outdir}/2.Trimming/Qtrim/${sample}"
    
    fastp -i ${reads[0]} \
          -I ${reads[1]} \
          -o ${sample}_1_Qtrimmed.fq.gz \
          -O ${sample}_2_Qtrimmed.fq.gz \
          -h ${sample}_Qtrimmed_summary.html \
          -n ${params.max_N} \
          -q ${params.minQscore} \
          -u ${params.scoreP} \
          --disable_adapter_trimming
    
    """

}