text="tsdfs"
num=4
sed -i "s/$(sed -n "${num}p" file_names.txt)/$text/g" file_names.txt

echo ${text/%s/.$num} 