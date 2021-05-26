#!/bin/bash

#join single SNPs into already defined groups


#for the Lamprey: we do a male map; a female map and a hybrid map 


#convert posterior into lepmap input
if [ $# -lt 2 ] ; then
    echo ""
    echo "usage: ./02.separate_chromosome.sh input LOD"
    echo "#join single markers into different chromosomes"
    echo "input should be of the form: map_....txt"
     echo "LOD: a string providing the LOD limit"
    echo ""
    exit 0
fi

input=${1}    #input from previous step 
output=$(basename $input) 
output=map_"$output"
LOD=${2}
STR=${3}     #optionnal 

#Lepmap option (minimal requirments)
NCPUS=10        #Use maximum of NUM threads [1]
lodLim=${LOD}   #LOD score limit [10.0]
lodDifference=2 #Required LOD difference [0.0]
dLod=1          #Use segregation distortion aware LOD scores [not set]
theta=0.01      #Fixed recombination fraction [0.03]

#optional: (uncomment to use
#STR="informativeMask=${STR}"    #Use only markers with 
                #informative father (1), mother(2), 
                 #both parents(3) or neither parent(0) [0123]
#bw="betweenSameType=1"
#iterate="iterate=1"       #Iterate single joining until no markers 
                #can be added (JoinSingles2All only) [not set]


#run the module with different lod threshold
echo join single2all with a lod of ${lodLim}
    zcat $input |\
       java -cp bin/ SeparateChromosomes2 data=- \
       lodLimit="$lodLim" \
       distortionLod=1 \
       numThreads="$NCPUS" \
       Theta="$theta" $STR $bw $iterate \
        > "$output"_LODLim"$lod"_size"$size"__STR"$STR"_js.txt

#old example
##joinSingle2All
##father only:
#zcat data_f.call0.10_0.01_v2.gz|\
#    java -cp ~/software/lepmap3/bin/ JoinSingles2All map=map_data_f.call0.10_0.001_10_father.txt data=- lodLimit=7 iterate=1 >map_father_js.txt
#
#mother only
#zcat data_f.call0.10_0.01_v2.gz|\
#    java -cp ~/software/lepmap3/bin/ JoinSingles2All  map=map_data_f.call0.10_0.001_10_mother.txt data=- lodLimit=7 iterate=1 >map_mother_js.txt
