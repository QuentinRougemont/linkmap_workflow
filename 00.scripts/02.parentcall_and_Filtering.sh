#!/bin/bash

#convert posterior into lepmap input
if [ $# -lt 2 ] ; then
    echo ""
    echo "usage: ./01.parentcall_and_filtering.sh  input.gz pedigree.t.txt"
    echo "run parent call and then filter data based on various parameters"
    echo ""
    exit 0
fi

input=${1}    #input from previous step
pedigree=${2} #pedigree file (eg.pedigree.txt)
output="data.call.gz"

zcat ${input}|\
    java ParentCall2 data=${pedigree} posteriorFile=- \
    removeNonInformative=1 ... |\
    gzip >${output}

echo "input ready for running parentcall"

# FILERTING #
echo "filtering input file now"

input=$outpout
output="data_f.call"
tol=0.001        #change according to your need
miss=0.015       #change according to your need
MAF=0.01         #change according to your need #this parameter seems to have no impact so I don"t use it really

zcat $input |\
   java -cp bin/ Filtering2 data=- \
   removeNonInformative=1 \
   dataTolerance=$tol \
   missingLimit=${miss} \
   MAFLimit=${MAF} | gzip > $output_miss"$miss"_tol"$tol".gz
   
echo "input is filtered" 
echo "you can run the next step"
