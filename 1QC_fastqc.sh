#!/bin/bash

# +++ setting: conda env bio +++

in_dir=$1 # path variable where rawdata file are located
out_dir=$2 # path variable where qc files should be saved

# --- Parameters ---
multi_core=6

# --- Function ---
function QCstep() {
	
	for read_file in "$in_dir/*.fq.gz"
	do
		basename_readfile=$(basename $read_file)
		if [[ $basename_readfile =~ .*trimmed.fq.gz ]]; then #check raw data or filtered data
			dir_name="QC_trimmed"
		else
			dir_name="QC_raw"
		fi

		mkdir -p "$out_dir/$dir_name"


		fastqc $read_file \
			-t $multi_core \
			-o "$out_dir/$dir_name" 

	done
}

QCstep


