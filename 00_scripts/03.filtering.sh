#!/bin/bash

#convert posterior into lepmap input
if [ $# -lt 2 ] ; then
    echo ""
    echo "usage: ./03.filtering.sh  input.gz pedigree.t.txt"
    echo "run parent call and then filter data based on various parameters"
    echo ""
    exit 0
fi

input=${1}      #input from previous step (eg. should be 07_lepmap/data.call.gz)
pedigree=${2}   #pedigree file (eg.pedigree.txt)

# FILERTING #
echo "filtering input file now"
output="${input%.gz}"
tol=0.0001        #change according to your need
miss=0.20         #change according to your need
MAF=0.05          #change according to your need

zcat $input |\
   java -cp ~/bin/ Filtering2 data=- \
   removeNonInformative=1 \
   dataTolerance=$tol \
   missingLimit=${miss} \
   MAFLimit=${MAF} | gzip > 07_lepmap/"$output"_miss"$miss"_tol"$tol"_MAF"$MAF".gz

echo "input is filtered"
echo "you can run the next step"
