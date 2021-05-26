#!/bin/bash
#### improved order of mother:
#move into the wanted folder,
#then use csplit to split the chromosome:

#script to be modified enteirely....


for i in $(seq 5) ; do 
mkdir -p run"$i"/log
done

for j in run* ; do
    for i in  LG* ; 
    do 
    zcat data_f.call0.10_0.01_v2.gz |\
        java -cp ~/software/lepmap3/bin/ OrderMarkers2 \
            evaluateOrder="$i" \
            informativeMask=23 \
            numThreads=5 \
            data=-  >"$j"/order_mother_improved__1."$i".txt  2>"$j"/err_motther_improved_1.chr"$i".txt 
            #chromosome="$i" 
    done ;
done 

#father:
for j in run* ; do
    for i in  LG* ; 
    do 
        zcat data_f.call0.10_0.01_v2.gz |\
            java -cp ~/software/lepmap3/bin/ OrderMarkers2 \
            evaluateOrder="$i" \
            informativeMask=13 \
            numThreads=10 \
            data=-  >"$j"/order_father_improved__1."$i".txt  2>"$j"/log/err_father_improved_1.chr"$i".txt 
        #chromosome="$i" 
    done ; 
done


zcat data.call.gz|cut -f 1,2|awk '(NR>=7)' >snps.txt
#note that first line of snps.txt contains "CHR POS"
awk -vFS="\t" -vOFS="\t" '(NR==FNR){s[NR-1]=$0}(NR!=FNR){if ($1 in s) $1=s[$1];print}' snps.txt order.txt >order.mapped
#because of first line of snps.txt, we use NR-1 instead of NR
