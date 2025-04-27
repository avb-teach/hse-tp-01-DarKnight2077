#!/bin/bash

input_directory="$1"
output_directory="$2"
code_word_max_depth="$3"
max_depth="$4"

if [ "$code_word_max_depth" = "" ] || [ "$max_depth" = "" ] || [ "$max_depth" = "1" ]; then
    find $input_directory -type f > files_to_copy.txt
    grep -E '' files_to_copy.txt | rev | cut -d'/' -f1 | rev > file_names.txt

    for item in $(cat files_to_copy.txt)
    do
    files_array+=($item)
    done

    processed_lines=""
    current_line=1
    for file_name_considered in $(cat file_names.txt)
    do
    if ! [[ $processed_lines == *"$current_line"* ]]; then
        cnt=0
        n=0
        match_indexes=()
        for current_file_name in $(cat file_names.txt)
        do
        if [ "$file_name_considered" = "$current_file_name" ]; then
            cnt=$(($cnt+1))
            match_indexes+=($n)
        fi
        n=$(($n+1))
        done

        if [ "$cnt" -gt "1" ]; then
            name_index=1
            line_num=1
            dot="."
            name_length=${#file_name_considered}
            for i in ${match_indexes[*]}
            do
            current_file=${files_array[$i]}
            current_file_length=${#current_file}
            position_to_start=$(($current_file_length-$name_length))
            current_file_address=$(echo $current_file | cut -c1-$position_to_start)
            name=${file_name_considered%.*}
            file_extension=${file_name_considered#*.}
            new_file_name_after_copying="$output_directory/$name$name_index$dot$file_extension"
            cp $current_file $new_file_name_after_copying
            line_num=$(($i+1))
            processed_lines="$processed_lines$line_num"
            name_index=$(($name_index+1))
            done
        else
            current_file=${files_array[${match_indexes[0]}]}
            cp $current_file $output_directory
        fi
    fi
    current_line=$(($current_line+1))
    done
else
    find $input_directory -type d -empty -delete # Удалим все пустые папки
    find $input_directory -maxdepth $(($max_depth-1)) -type d -print > temp.txt
    sed -i 1d temp.txt # Удалим сразу ненужную первую строку с самой директорией
    find $input_directory -maxdepth $max_depth -type d -print > temp1.txt
    sed -i 1d temp1.txt 
    cat temp1.txt temp.txt temp.txt | sort | uniq -u > temp2.txt # Запишем папки, располагающиеся на максимальной допустимой глубине

    ans_to_bring_num=$(($max_depth-2))

    cnt=0
    c=$input_directory
    while [ "$c" != "" ]     # Надо как в new.sh пообрезать слева, но только надо так, чтобы от уровня директории главной мы отрезали max_depth-ans_to_bring_num раз. Потом уже с результатом работать над переносом его наверх.
    do
    c=$(echo ${c#*/})
    cnt=$(($cnt+1))
    if [ "$c" = "$(echo ${c#*/})" ]; then
        break
    fi
    done
    default_level=$(echo $cnt)

    if [ "$ans_to_bring_num" -gt "0" ]; then  # Определяем, берем ли мы с собой наверх предков
        while [ -s temp2.txt ]; do  # Продолжаем программу, если на максимальной допустимой глубине вообще располагаются какие-то папки. !Сделать это не единичным условием, а условием цилка while, в котором temp2.txt будет итерационно обновляться. + В конце каждой итерации удалять во всей директории пустые папки, чтобы удалять новоиспеченные ветки, которые в изначальной структуре хранили где-то внизу файл, но при обособлении при данном параметре глубины они пусты.
            for current_folder_address in $(cat temp2.txt)
            do
            f=$current_folder_address
            cnt=0
            while [ $cnt -le $(($default_level+$ans_to_bring_num)) ]; do
                f=$(echo ${f#*/})
                cnt=$((cnt+1))
            done
            mkdir -p $input_directory/$f
            cp -r $current_folder_address/* $input_directory/$f/
            rm -r $current_folder_address
            done
            
            find $input_directory -type d -empty -delete # Удалим все пустые папки
            find $input_directory -maxdepth $(($max_depth-1)) -type d -print > temp.txt
            sed -i 1d temp.txt # Удалим сразу ненужную первую строку с самой директорией
            find $input_directory -maxdepth $max_depth -type d -print > temp1.txt
            sed -i 1d temp1.txt 
            cat temp1.txt temp.txt temp.txt | sort | uniq -u > temp2.txt # Запишем папки, располагающиеся на максимальной допустимой глубине
        done
    else
        while [ -s temp2.txt ]; do  # Продолжаем программу, если на максимальной допустимой глубине вообще располагаются какие-то папки. !Сделать это не единичным условием, а условием цилка while, в котором temp2.txt будет итерационно обновляться. + В конце каждой итерации удалять во всей директории пустые папки, чтобы удалять новоиспеченные ветки, которые в изначальной структуре хранили где-то внизу файл, но при обособлении при данном параметре глубины они пусты.
            folder_names=($(grep -E '' temp2.txt | rev | cut -d'/' -f1 | rev))
            folder_addresses=($(cat temp2.txt))
            for (( i=0; i <= $(($(grep -c $ temp2.txt)-1)); i++ ))
            do
            mkdir -p $input_directory/${folder_names[i]}
            cp -r ${folder_addresses[i]}/* $input_directory/${folder_names[i]}/
            rm -r ${folder_addresses[i]}
            done
            
            find $input_directory -type d -empty -delete # Удалим все пустые папки
            find $input_directory -maxdepth $(($max_depth-1)) -type d -print > temp.txt
            sed -i 1d temp.txt # Удалим сразу ненужную первую строку с самой директорией
            find $input_directory -maxdepth $max_depth -type d -print > temp1.txt
            sed -i 1d temp1.txt 
            cat temp1.txt temp.txt temp.txt | sort | uniq -u > temp2.txt # Запишем папки, располагающиеся на максимальной допустимой глубине
        done
    fi
    cp -r $input_directory/* $output_directory/
fi
