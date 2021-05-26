
map=$1

csplit --suppress-matched --prefix LG --suffix-format %02d $map '/LG = /' '{*}'

rm LG00
for i in LG* ;
do 
    sed -i "s/^/$i\t/g" "$i" 
    sed -i 1d "$i" ;
done

cat LG* > map_reshaped
cut -f 1-5 map_reshaped |awk '{print $0"\t"$2"_"$3 }' >  tmp
echo -e "LG\tCHR\tPOS\tmale_pos\tfemale_pos\tCHR_POS" > header
cat header tmp > "$map"_reshaped.txt 
rm tmp header 
