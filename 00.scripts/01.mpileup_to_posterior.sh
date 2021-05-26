#!/bin/bash

#converting bam to posterior for lepmap

ls 04-list_bam/*sorted*bam > list_sorted_bam.txt

samtools mpileup -q 20 -Q 20 -s $(cat list_sorted_bam.txt)|java -cp bin/ Pileup2Likelihoods|gzip >post.gz
