process cutadapt{

    publishDir "${params.outdir}/2.Trimming/Atrim/${sample}", mode: 'copy'

    input:
    tuple val(sample),path(reads)

    output:
    tuple val("${sample}"),path("${sample}_*_Atrimmed.fq.gz"),emit:atrim

    script:
    """
    mkdir -p "${params.outdir}/2.Trimming/Atrim/${sample}"
    
    cutadapt -a ${params.for_primer_seq} \
             -A ${params.rev_primer_seq} \
             -o ${sample}_1_Atrimmed.fq.gz \
             -p ${sample}_2_Atrimmed.fq.gz \
             ${reads[0]} \
             ${reads[1]} \
             --pair-filter=${params.filter_mode} \
             --discard-trimmed \
             --cores=${params.cores_nr}
    """
}