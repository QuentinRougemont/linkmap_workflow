#!/bin/bash

#converting bam to posterior for lepmap

ls 05_aligned/*sorted*bam > list_sorted_bam.txt
mkdir 06_posterior

samtools mpileup -q 20 -Q 20 -s $(cat list_sorted_bam.txt)|java -cp bin/ Pileup2Likelihoods|gzip >06_posterior/post.gz
