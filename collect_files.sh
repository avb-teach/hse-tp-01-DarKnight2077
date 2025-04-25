#!/bin/bash
input_directory="$1"
output_directory="$2"

find $input_directory -type f > files_to_copy.txt

for file in $(cat files_to_copy.txt)
do
cp $file $output_directory
done