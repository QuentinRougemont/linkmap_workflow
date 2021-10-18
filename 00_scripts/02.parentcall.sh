#!/bin/bash

#convert posterior into lepmap input
if [ $# -lt 2 ] ; then
    echo ""
    echo "usage: ./02.parentcall.sh  input.gz pedigree.t.txt"
    echo "run parent call and then filter data based on various parameters"
    echo ""
    exit 0
fi

input=${1}      #input from previous step (06_posterior/post.gz)
pedigree=${2}   #pedigree file (eg.pedigree.txt)
output="data.call.gz"

zcat ${input}|\
    java ParentCall2 data=${pedigree} posteriorFile=- \
    removeNonInformative=1 |\
    gzip >07_lepmap/${output}

echo "input ready for running parentcall"

