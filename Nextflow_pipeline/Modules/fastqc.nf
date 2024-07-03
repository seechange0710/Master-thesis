process fastqc {
    publishDir "${params.qc_raw_out}/${sample}/1.QC", mode: 'copy'

    input:
    tuple val(sample),path(read)

    output:
    path("*_fastqc.{zip,html}")

    script:
    """
    mkdir -p "${params.qc_raw_out}/${sample}/1.QC"
    fastqc $read -t $params.cores_nr
    """
}