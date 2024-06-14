#!/bin/bash

# +++ setting: conda env bio +++
### always give full path, i.e. start with /Users/... instead of using ~

in_dir=$1
out_dir=$2
sample_list=$3

# --- Parameters ---
### reads are allowed to have maximal 15N
### when bases whose quality(Qscore) is lower than 20 accounting for more than 50% of a read, this read will be filtered out
max_N=15
min_Qscore=20
Portion_min_Qscore=50

# --- Function ---
function check_sampleList(){

	if [ -f "$out_dir/sample_list.txt" ] # check possible already exisiting sample_list file in output dir and remove it
	then
		rm "$out_dir/sample_list.txt"
	else
		continue
	fi
}

function Quali_trim() {

	iteration=0
	#dir=$in_dir

	file_num=$(cat "$sample_list" | wc -l) # number of files need to be treated
	sample_num=$((file_num / 2)) # number of samples since each sample has two paired read files

	while true
	do

		current_file=$((1 + iteration*2)) # position of being treated file (file1) in sample list
		paired_currentfile=$((current_file + 1)) # position of corresponding paired file (file2)
		file_1=$(sed -n "${current_file}p" $sample_list) # retrieve full path of file1
		file_2=$(sed -n "${paired_currentfile}p" $sample_list) # retrieve full path of file2 
		basename_file1=$(basename $file_1 | cut -d "." -f 1) # name of file1 without sufix
		basename_file2=$(basename $file_2 | cut -d "." -f 1) # name of file2 without sufix
		sample_name=${basename_file1%_*} # name of sample = name of file1/2 - sequencing direction flag(1 or 2)
		out_file1="$out_dir/${basename_file1}-Qtrimmed.fq.gz" # output file of file1
		out_file2="$out_dir/${basename_file2}-Qtrimmed.fq.gz" # output file of file2
		
		echo "FASTP is now being conducted on $(basename $file_1) and $(basename $file_2)"
		
		if [ -f $file_1 ] && [ -f $file_2 ]
		then
			fastp -i $file_1 \
			-I $file_2 \
			-o $out_file1 \
			-O $out_file2 \
			-h "$out_dir/${sample_name}-Qtrimming.html" \
			-n $max_N \
			-q $min_Qscore \
			-u $Portion_min_Qscore \
			--disable_adapter_trimming \
			#--detect_adapter_for_pe

		
			echo "$out_file1" >> "$out_dir/sample_list.txt" # document output file path to sample_list for downstream retrieval
			echo "$out_file2" >> "$out_dir/sample_list.txt"
		
		else
			echo "${file_1} and/or ${file_2} can not be recognized as file!" # error occurs when bash does not take file path [can not open file]
		fi
		

		if (( iteration < sample_num - 1 )) # if files left to be treated
		then
			iteration=$((iteration + 1)) # when yes, move to next file
		else
			break # when no, quit
		fi
	done

}

check_sampleList
Quali_trim