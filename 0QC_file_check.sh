#!/bin/bash

path=$1 # path variable of inpyt files (raw read files)

function check_file() {
### check if samples have paired read files ###


in_dir=$path


for file in $in_dir/*
do
	#echo "$(basename $file)"
	if [ -f $file ] 
	then
		if [[ $file =~ .*\.fq.gz ]] # only apply to read files
		then	
			empty_flag=$((empty_flag+1))
			sample_file_name=$(basename $file | cut -d "." -f 1) # extract sample name + read direction flag
			sample_read_type=$(echo $sample_file_name | rev | cut -d "_" -f 1) # extract read direction flag (1-fw or 2-rev)
			sample_base_name=${sample_file_name%_*} # extract sample name
				

			if [[ $sample_read_type == 1 ]] # determine which read file is being looked at
			then
				second_file="$in_dir/${sample_base_name}_2.fq.gz" # search for pair file
			else
				second_file="$in_dir/${sample_base_name}_1.fq.gz" # search for pair file
			fi

			
			if [ -f $second_file ] # test if pair file exist
			then
				new_dir_name="$in_dir/success" # when yes, both of files will be moved to a separate dir (success)
				mkdir -p $new_dir_name
				mv $file $second_file $new_dir_name
				echo "----success: sample ${sample_base_name} has paired read files!----"
				file_new_path="$new_dir_name/$(basename $file)"
				secfile_new_path="$new_dir_name/$(basename $second_file)"
				echo "$file_new_path" >> "$in_dir/sample_list.txt" # create sample_list file including all read files for the sake of downstream analysis
				echo "$secfile_new_path" >> "$in_dir/sample_list.txt"
			else
				new_dir_name="$in_dir/fail" # otherwise, sample lacking pair read files will be moved to dir (failed)
				mkdir -p $new_dir_name
				mv $file $new_dir_name
				echo "----fail: sample ${sample_base_name} misses paired read file!----"
			fi
		else
			continue # eitehr as paired file being already looked or other file format, skip and do nothing
		fi

	fi

	if [ -d $file ] # do nothing on subdirs
	then
		continue # skip and do nothing
	fi
done

}

check_file
