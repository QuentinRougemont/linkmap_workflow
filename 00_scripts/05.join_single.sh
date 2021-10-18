#!/bin/bash
#join single SNPs into already defined groups
if [ $# -lt 4 ] ; then
    echo ""
    echo "usage: ./05.join_single.sh data map LodLimit LodDifference"
    echo "#join single markers into different chromosomes"
    echo "1 - data should be the filtered genotype likelihood obtained from 07.filter.sh"
    echo "2 - map  is the map obtained at previous step after splitting group"
    echo "3 - LodLimit: a string providing the LOD limit"
    echo "4 - LodDifference: a string providing the difference in lod"
    echo ""
    exit 0
fi

#arguments:
data=${1}     #data_f.call.gz
map=${2}      #name of the best map obtained from the previous scripts
LodLim=${3}   #LOD score limit [10.0]
LodDiff=${4}  #Required LOD difference [0.0]

#prepare env:
mkdir 08_map_wanted ; cd 08_map_wanted
#example:
#ln -s ../08_map/map_data_f.call_miss0.20_tol0.0001_MAF0.05.gz_LOD5_size_STR123_maleThetamaleTheta\=0.5_femaleThetafemaleTheta\=0.0.txt wanted_map_miss20.txt
ln -s ../$map wanted_map.txt
cd ../

mkdir 09_join_single
output=09_join_single/map_iterated_LodLim"$LodLim".LodDiff"$Loddiff".txt

#Lepmap option (minimal requirments)
NCPUS=10                       #Use maximum of NUM threads [1]
llim="lodLimit=$LodLim"
ldif="lodDifference=$LodDiff"  #Required LOD difference [0.0]
dLod=1                         #Use segregation distortion aware LOD scores [not set]
f="femaleTheta=0.0"            #NUM 
m="maleTheta=0.5"              #NUM 
#t="theta=0.05"                #Fixed recombination fraction [0.03]
it="iterate=1"                 #Iterate single joining until no markers can be added (JoinSingles2All only) [not set]

#run the module with different lod threshold
echo join single2all with a lod of ${lodLim}
zcat $data |\
    java -cp ~/work/softwares/lep-map3/bin/ JoinSingles2All \
    map=08_map_wanted/wanted_map.txt \
    data=-  \
    $llim \
    $ldif \
    $m $f $t $it \
    >$output

awk '{print $1}' $output |sort -n |uniq -c > "${output%.txt}".distribution
