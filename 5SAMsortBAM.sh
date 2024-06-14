#!/bin/bash

# +++ setting: +++

in_dir=$1
out_dir=$2

# --- Parameters ---

multi_core=6
output_fmt="bam"

# --- Functions ---

function SAMsortBAM(){

	for file in "$in_dir/*"
	do
		samplename="${file%%.*}"
		samtools sort -@ $multi_core \
					$file \
					-O $output_fmt \
					-o "$out_dir/$samplename.sorted.bam"
	done
}

SAMsortBAM