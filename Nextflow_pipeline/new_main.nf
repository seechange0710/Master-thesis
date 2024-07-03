// General parameters
params.indir = "${launchDir}/Data"
params.outdir = "${launchDir}/Results"
params.modules = "${launchDir}/Modules"

// Input parameters
params.species = "BN"
params.reads = "${params.indir}/Raw_data/*_{1,2}.fq.gz"

// specific parameters
// fastp
params.max_N = 15
params.minQscore = 20
params.scoreP = 50

// cutadapt
params.for_primer_seq = "AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"
params.rev_primer_seq = "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"
params.filter_mode = "both"
params.cores_nr = 6

// hisat2
params.map_reference = "${params.indir}/DB/Brassica_napus_AST_PRJEB5043.dna.fa"

// samtools & Htseq
params.fmt = "bam"
params.count_mode = "union"
params.count_type = "exon"
params.id_attr = "gene_id"
params.add_attr = "gene_name"
params.stranded_para = "no"
params.sort_flag = "pos"
params.annotation_reference = "${params.indir}/DB/Brassica_napus.AST_PRJEB5043_v1.59.gtf.gz"


reads_ch = Channel
            .fromFilePairs( params.reads, checkIfExists:true )

log.info """
    R  N  A  s  e  q - P  I  P  E  L  I  N  E
    +++++++++++++++++++++++++++++++++++++++++
    
    1.Quality Control   -->            fastqc
            |
       2.Trimming       -->  fastp & cutadapt
            |
       3.Alignment      -->            Hisat2
            |
     4.Quantification   -->  samtools & Htseq
    
    ++++++++++++++++++++++++++++++++++++++++++
                   *Settings*
    ==========================================
                    General
    Data-folder      : ${params.indir}
    Results-folder   : ${params.outdir}
    ==========================================
                Input & References
    Reads-Input      : ${params.reads}
    mapping reference: ${params.map_reference}
    gene annotation  : ${params.annotation_reference}
    ==========================================
                    FastP
    maximal N's      : ${params.max_N}
    minimal Q-score  : ${params.minQscore}
    Q-score portion  : ${params.scoreP}
    ==========================================
                    Cutadapt
    forward-primer   : ${params.for_primer_seq}
    reverse-primer   : ${params.rev_primer_seq}
    read-filter-mode : ${params.filter_mode}
    core-used        : ${params.cores_nr}
    ==========================================
                    HISAT2
    core-used        : ${params.cores_nr}
    ==========================================
                    Samtools
    sort-by          : ${params.sort_flag}
    ==========================================
                    HtSeq
    count-mode       : ${params.count_mode}

"""

include{ fastp } from "${params.modules}/fastp.nf"
include{ cutadapt } from "${params.modules}/cutadapt.nf"
include{ hisat2_idx; hisat2_ali } from "${params.modules}/hisat2.nf"
include{ samSortBam; htseq } from "${params.modules}/htseq.nf"


workflow{
    
    //Trimming
    fastp(reads_ch)
    cutadapt(fastp.out.qtrim)

    //Index building & Aligment
    //hisat2_idx("${params.map_reference}")
    hisat2_idx( params.map_reference )
    hisat2_ali(cutadapt.out.atrim, hisat2_idx.out.index)

    //Sort & Quantification
    sam_ch = hisat2_ali.out.sam.flatten().map{
        file -> def samplename = file.name.split('\\.')[0] //input channel with samplename and file path
        return [samplename,file]
    }
    samSortBam(sam_ch)

    sbam_ch = samSortBam.out.sbam.flatten().map{
        file -> def samplename = file.name.split('\\.')[0] //input channel with samplename and file path 
        return [samplename, file]
    }
    htseq(sbam_ch, params.annotation_reference)
}