#separate chr

#seaprate the snps into different chromosomes according to linkage level.
#LOD script determine levels of stringeancy
#If LOD it too low evey chromosome will tend to be merge together due to 
#too relaxed linkage stringeancy
#If LOD is too high then there might be too many small chromsome

#for the Lamprey: we do a male map; a female map and a hybrid map 

#convert posterior into lepmap input
if [ $# -lt 2] ; then
    echo ""
    echo "usage: ./02.separate_chromosome.sh input STR"
    echo "#seaprate the snps into different chromosomes"
    echo "input should be of the form: datat_miss_tol.gz"
    echo "STR: Use only markers with informative "
    echo "father (1), mother(2), both parents(3) "
    echo "or neither parent(0) [0123]"
    echo ""
    exit 0
fi

input=${1}   #input from previous step 
             #should be of the form: $data_f.call_miss"$miss"_tol"$tol".gz
STR=${2}     #0,1,2,3

output=$(basename $input) 
output=map_"$output"

#Lepmap option (minimal requirments)
NCPUS=10   #Use maximum of NUM threads [1]
dLod=1     #Use segregation distortion aware LOD scores [not set]
theta=0.01 #Fixed recombination fraction [0.03]
SIZE=50    #Remove LGs with < NUM markers [1]
STR=${STR}    #Use only markers with informative father (1), mother(2), 
           #both parents(3) or neither parent(0) [0123]


#run the module with different lod threshold
for i in $(seq 2 9)  ; do
    lod=$i
    echo separate markers for lod score: ${lod}
    zcat $input |\
       java -cp bin/ SeparateChromosomes2 data=- \
       lodLimit="$lod" \
       informativeMask=$STR
       distortionLod=1 \
       numThreads="$NCPUS" \
       sizeLimit="$SIZE" \
       Theta="$theta" > "$output"_LOD"$lod"_size"$size"_STR"$STR".txt
done


awk '{print $1}' "$output"_LOD"$lod"_size"$size"_STR"$STR".txt |\
    sort -n | \
    uniq -c > "$output"_LOD"$lod"_"size"_distribution
#awk '{print $1}' "$output"_LOD"$lod"_size"$size".txt |sort|uniq -c|sort -n

