processed_lines="1"
num=1
for file in $(cat files_to_copy.txt)
do
processed_lines="$processed_lines$num"
echo $processed_lines
done
string='Моя длинна строка'
if ! [[ $string == *"gby"* ]]; then
  echo "Подстрока не найдена!"
fi