#!/bin/bash

# +++ setting: +++

count_out=$1
gtf_file=$2
#bam_in=$3


# --- Parameters ---

count_mode="union"
in_format="bam"
count_type="exon"
id_attr="gene_id"
ad_attr="gene_name"
stranded_para="no" # pair-ended sequencing
sort_flag="pos" # samtools sort /input/file/path -u -O bam -o /output/file/path 
bam_in="/Users/sichengxu/Documents/Brassica_napus/NN_data/3.Alignment/Results/*.sortedP.bam"
#gtf_file="~/Documents/Brassica_napus/NN_data/3.Alignment/Preparation/Gene_annotation/Brassica_napus.AST_PRJEB5043_v1.59.gtf.gz"
#count_out="~/Documents/Brassica_napus/NN_data/3.Alignment/Results/Bn3CL-count-sorted.csv"
parallel_core=6



# --- Functions ---

#for file in "$bam_in/*_sortedP.bam"
#	echo $file

if [ -f $gtf_file ]
then
	htseq-count -m $count_mode \
				-c $count_out \
				-f $in_format \
				-s $stranded_para \
				-t $count_type \
				-i $id_attr \
				--additional-attr=$ad_attr \
				-r $sort_flag \
				-n $parallel_core \
				$bam_in \
				$gtf_file
else
	echo "No such file or dir for GTF : path [${gtf_file}]"
fi
#done
