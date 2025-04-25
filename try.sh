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

if [ "$cnt" -gt "1" ] && ! [[ $processed_lines == *"$current_line"* ]]; then
    name_index=1
    line_num=1
    dot="."
    name_length=${#file_name_considered}
    for file in $(cat files_to_copy.txt)
    do
    current_file_length=${#file}
    position_to_start=$(($current_file_length-$name_length))
    if [ "$position_to_start" -gt "0" ]; then
        current_file_name=$(echo $file | cut -c$position_to_start-$current_file_length)
        if [ "/$file_name_considered" = "$current_file_name" ]; then
            current_file_adress=$(echo $file | cut -c1-$position_to_start)
            name=${file_name_considered%.*}
            file_extension=${current_file_name#*.}
            new_file_name="$current_file_adress$name$name_index$dot$file_extension"
            echo $new_file_name
            processed_lines="$processed_lines$line_num"
            name_index=$(($name_index+1))
        fi
        
    fi
    line_num=$(($line_num+1))
    done
fi
current_line=$(($current_line+1))
done



