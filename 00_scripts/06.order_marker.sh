#!/bin/bash
#then use csplit to split the chromosome:

data=$1 #example: 07_lepmap/data_f.call_miss0.20_tol0.0001_MAF0.05.gz #$1
map=$2  #example: 09_join_single/map_miss0.20_tol0.0001_single.iterated_lodLimit4LodDiff2.txt #$2

awk '{print $1}' $map |sort |uniq -c |sort -k 2 -n |sed 1,2d |awk '{print $2}'  >> chromolist

base_map=$(basename $map )
rm 10.ordered_"$base_map" 2>/dev/null
rm 10.ordered_evaluated."$base_map" 2>/dev/null

mkdir -p 10.ordered_"$base_map"/

for LG in $(cat chromolist ) ; do
	echo "order markers for LG $LG"
	zcat $data |\
		java -cp ~/work/softwares/lep-map3/bin/ OrderMarkers2 \
		map=$map \
		numThreads=5 \
			recombination2=0 \
			chromosome=$LG \
			numMergeIterations=6 \
			outputPhasedData=1 \
               data=- >10.ordered_"$base_map"/order_LG"$LG".txt 2>10.ordered_"$base_map"/stdout_LG"$LG".txt  
	     
		infile=10.ordered_"$base_map"/order_LG"$LG".txt
         
		#mkdir 10.ordered_evaluated_"$map"

		for rep in $(seq 5 ) ; 
		echo "evaluate order for LG $LG and rep $rep"
		do
		mkdir -p 10.ordered_evaluated_"$base_map"/"$rep"

			zcat $data |\
			java -cp ~/work/softwares/lep-map3/bin/ OrderMarkers2 \
			evaluateOrder=$infile \
			numThreads=5 \
			data=- \
			numMergeIterations=6 \
			recombination2=0 \
			chromosome=$LG \
			outputPhasedData=1 >10.ordered_evaluated_"$base_map"/"$rep"/order_evaluated_LG"$LG".txt 2>10.ordered_evaluated_"$base_map"/"$rep"/stdout_LG"$LG".txt
		done
done ;

zcat $data | cut -f 1,2 | awk '(NR>=7)' >snps.txt
exit
#search the best replicate before running this line:
#note that first line of snps.txt contains "CHR POS"
awk -vFS="\t" -vOFS="\t" '(NR==FNR){s[NR-1]=$0}(NR!=FNR){if ($1 in s) $1=s[$1];print}' snps.txt order.txt >order.mapped
#because of first line of snps.txt, we use NR-1 instead of NR
