#!/bin/bash
#separate the snps into different chromosomes according to linkage level.
#LOD score determine levels of stringeancy
#If LOD it too low every chromosome will tend to be merge together due to 
#If LOD is too high then there might be too many small chromosomes

if [[ $# -lt 2 ]] ; then
    echo ""
    echo "usage: ./04.separate_chromosome.sh input STR"
    echo "#seaprate the snps into different chromosomes"
    echo "input should be of the form: datat_miss_tol.gz"
    echo "STR: Use only markers with informative "
    echo "father (1), mother(2), both parents(3) "
    echo "or neither parent(0) [0123]"
    echo ""
    exit 0
fi

#manadtory arguments:
input=${1}   #input from previous step 
             #should be of the form: $data_f.call_miss"$miss"_tol"$tol".gz
STR=${2}     #0,1,2,3

output=$(basename $input) 
output=map_"$output"
ftheta=0
mtheta=0.5
#Lepmap option (minimal requirments)
#comment irrelevant argument
NCPUS=10                   #Use maximum of NUM threads [1]
dLod="distortionLod=1"     #Use segregation distortion aware LOD scores [not set]
f="femaleTheta=$ftheta"    #NUM 
m="maleTheta=$mtheta"      #NUM 
#t="theta=0.05"            #Fixed recombination fraction [0.03]
SIZE=20                    #Remove LGs with < NUM markers [1]
STR=${STR}                 #Use only markers with informative father (1), mother(2), 
                           #both parents(3) or neither parent(0) [0123]

mkdir 08_map 2>/dev/null
#run the module with different lod threshold
for i in $(seq 2 20)  ; do
    lod=$i
    echo separate markers for lod score: ${lod}
    zcat $input |\
       java -cp ~/bin/ SeparateChromosomes2 data=- \
       lodLimit="$lod" \
       informativeMask=$STR \
       $f $m $t $dLod \
       numThreads="$NCPUS" \
       sizeLimit="$SIZE" \
       > 08_map/"$output"_LOD"$lod"_size"$size"_STR"$STR"_maleTheta"$mtheta"_femaleTheta"$ftheta".txt

    awk '{print $1}' 08_map/"$output"_LOD"$lod"_size"$SIZE"_STR"$STR"_maleTheta"$mtheta"_femaleTheta"$ftheta".txt |\
        sort -n | uniq -c \
        > 08_map/"$output"_LOD"$lod"_size"$SIZE"_STR"$STR"_maleTheta"$mtheta"_femaleTheta"$ftheta".distribution
done
