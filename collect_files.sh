#!/bin/bash

input_directory="$1"
output_directory="$2"

find $input_directory -type f > files_to_copy.txt
grep -E '' files_to_copy.txt | rev | cut -d'/' -f1 | rev > file_names.txt

processed_lines=""
current_line=1
for file_name_considered in $(cat file_names.txt)
do
cnt=0

for current_file_name in $(cat file_names.txt)
do
if [ "$file_name_considered" = "$current_file_name" ]; then
    cnt=$(($cnt+1))
fi
done

if ! [[ $processed_lines == *"$current_line"* ]]; then
    name_index=1
    line_num=1
    dot="."
    name_length=${#file_name_considered}
    for file in $(cat files_to_copy.txt)
    do
    current_file_length=${#file}
    position_to_start=$(($current_file_length-$name_length))
    if [ "$position_to_start" -gt "0" ]; then
        current_file_name_with_forward_slash=$(echo $file | cut -c$position_to_start-$current_file_length)
        if [ "/$file_name_considered" = "$current_file_name_with_forward_slash" ]; then
            if [ "$cnt" -gt "1" ]; then
                current_file_adress=$(echo $file | cut -c1-$position_to_start)
                name=${file_name_considered%.*}
                file_extension=${file_name_considered#*.}
                new_file_name_after_copying="$output_directory/$name$name_index$dot$file_extension"
                cp $file $new_file_name_after_copying
                processed_lines="$processed_lines$line_num"
                name_index=$(($name_index+1))
            else
                cp $file $output_directory
            fi
        fi
        
    fi
    line_num=$(($line_num+1))
    done
fi
current_line=$(($current_line+1))
done