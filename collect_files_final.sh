chmod +x collect_files.sh

input_directory="$1"
output_directory="$2"

find $input_directory -type f > files_to_copy.txt
grep -E '' files_to_copy.txt | rev | cut -d'/' -f1 | rev > file_names.txt

for file_name_considered in $(cat file_names.txt)
do
cnt=0
for file_name in $(cat file_names.txt)
do
if [ "$file_name_considered" == "$file_name" ]; then
    ((cnt+=1))
fi
done
if [ "$cnt" -gt "1" ]; then
    ((cnt+=1))
fi
done



for file in $(cat files_to_copy.txt)
do
cp $file $output_directory
echo "$file has been copied"
done

