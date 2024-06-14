#!/bin/bash

# +++ setting: no requirements +++
in_dir=$1
out_dir=$2
sample_list=$3


# --- Parameters ---
Bn_DNA_fa="/Users/sichengxu/Documents/Brassica_napus/NN_data/3.Alignment/Preparation/Gene_annotation/Brassica_napus_AST_PRJEB5043.dna.fa"
multi_core=6
BN_index_path="/Users/sichengxu/Documents/Brassica_napus/NN_data/3.Alignment/Preparation/BN_db/BN_Index"

# --- Functions ---
function build_index(){
	db_dir=$(dirname $BN_index_path) # test if database folder exist
	if [ -d $db_dir ]
	then
		for file in $db_dir/*
		do

			if [[ "$file" =~ .*\.ht2 ]] # test if index is present
			then
				echo "index already exists"
				break
			else
				echo "no index"
				hisat2-build -f $Bn_DNA_fa $BN_index_path # when no then build new index
				break
			fi
		done
	else
		echo "data base is not present!"
		exit 2
	fi
}


function alignment_HISAT(){

	iteration=0

	file_num=$(cat "$sample_list" | wc -l) # number of files need to be treated
	sample_num=$((file_num / 2)) # number of samples since each sample has two paired read files

	while true
	do
		current_file=$((1 + iteration*2)) # position of being treated file (file1) in sample list
		paired_currentfile=$((current_file + 1)) # position of corresponding paired file (file2)
		file_1=$(sed -n "${current_file}p" $sample_list) # retrieve full path of file1
		file_2=$(sed -n "${paired_currentfile}p" $sample_list) # retrieve full path of file2
		basename_file1=$(basename $file_1 | cut -d "." -f 1) # name of file1 without sufix
		sample_name=${basename_file1%_*} # name of sample = name of file1/2 - sequencing direction flag(1 or 2)
		output="$out_dir/${sample_name}.sam"
		summary="$out_dir/${sample_name}-summary.txt"

		echo "HISAT2 is now being conducted on $(basename $file_1) and $(basename $file_2)"

		hisat2 -p $multi_core \
				-x $BN_index_path \
				-1 $file_1 \
				-2 $file_2 \
				-S $output \
				--summary-file $summary
		
		if (( iteration < sample_num - 1 )) # if files left to be treated
		then
			iteration=$((iteration + 1)) # when yes, move to next file
		else
			break # when no, quit
		fi
	done

}


build_index
alignment_HISAT
