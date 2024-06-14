#!/bin/bash

# +++ setting: conda env cutadapt +++

in_dir=$1
out_dir=$2
sample_list=$3

# --- Parameters ---
### adapter sequences from Illumina TruSeq
### use multi_core mode of Cutadapt (6 cores)
### reads will be filtered out only if adapter contamination is found at both end of the read
adt_seq1="AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"
adt_seq2="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"
multi_core=6
filter_para="both"

# --- Funtion ---
function check_samplelist(){

	if [ -f "$out_dir/sample_list.txt" ]
	then 
		rm "$out_dir/sample_list.txt"
	else
		continue
	fi
}

function Adapt_trim() {

	iteration=0
	#dir=$in_dir

	#echo "$sample_list"
	file_num=$(cat "$sample_list" | wc -l) # number of files need to be treated
	sample_num=$((file_num / 2)) # number of samples since each sample has two paired read files

	while true
	do

		current_file=$((1 + iteration*2)) # position of being treated file (file1) in sample list
		paired_currentfile=$((current_file + 1)) # position of corresponding paired file (file2)
		file_1=$(sed -n "${current_file}p" $sample_list) # retrieve full path of file1
		file_2=$(sed -n "${paired_currentfile}p" $sample_list) # retrieve full path of file2 
		basename_file1=$(basename $file_1 | cut -d "." -f 1 | sed 's/\(.*\)-Qtrimmed/\1/' ) # name of file1 without sufix
		basename_file2=$(basename $file_2 | cut -d "." -f 1 | sed 's/\(.*\)-Qtrimmed/\1/' ) # name of file2 without sufix
		out_file1="$out_dir/${basename_file1}-Atrimmed.fq.gz" # output file of file1
		out_file2="$out_dir/${basename_file2}-Atrimmed.fq.gz" # output file of file2
		
		echo "CUTADAPT is now being conducted on $(basename $file_1) and $(basename $file_2)"
		
		cutadapt -a $adt_seq1 \
				-A $adt_seq2 \
				-o $out_file1 \
				-p $out_file2 \
				$file_1 \
				$file_2 \
				--pair-filter=$filter_para \
				--discard-trimmed \
				--cores=$multi_core
		
		echo "$out_file1" >> "$out_dir/sample_list.txt" # document output file path to sample_list for downstream retrieval
		echo "$out_file2" >> "$out_dir/sample_list.txt"

		if (( iteration < sample_num - 1 )) # if files left to be treated
		then
			iteration=$((iteration + 1)) # when yes, move to next file
		else
			break # when no, quit
		fi
	done
}

check_samplelist
Adapt_trim