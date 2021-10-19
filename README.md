# linkmap_workflow

# purpose:

constructing linkage map based on LepMap3 
Tested with F1 crosses on lampreys and *apollo parnasius*  


# Depandancies: 
   * Lepmap3 software available [here](https://sourceforge.net/p/lep-map3/code/ci/master/tree/)
   * download it and add the path to your bashrc
   * For alignment [bwa mem](https://sourceforge.net/projects/bio-bwa/files/) and [samtools](http://www.htslib.org) are required      
    


# **MAJOR STEPS:** 

 * **_1 preliminary step: alignment (and eventually SNP calling)_**  
 
        * Use **bwa** to align the data (see e.g. [this for RADseq](https://github.com/QuentinRougemont/stacks_v2_workflow/blob/master/00-scripts/04.bwa_mem_align_reads_pe.sh) ).  
        
        * An example script for bwa-mem can be find in `./00_scripts/00_bwa_mem.sh`   
        
        * in this case trimmed reads should be store in a folder `04_data` and the genome in `03_genome`  
          

 * **_2 convert bam to posterior_**
        * simply use the scripts provided with LepMap: pileup2likelihood:
 
 ```bash
 samtools mpileup -q 20 -Q 20 -s $(cat list_sorted_bam.txt)|\
 java -cp bin/ Pileup2Likelihoods|\
 gzip >post.gz  
        
 #Alternatively use the script:
 ./00.scripts/06_posterior/01.mpileup_to_posterior.sh
 ```

* **_3 run parentCall and filter_**
    * script to use is: `00_scripts/02.parentcall.sh` 
    example: 
    ```sh
    00_scripts/02.parentcall.sh input.gz pedigree.t.txt
    ```
    
    To filter the file then use : 
    ```bash
    00_scripts/03_Filtering.sh  input.gz pedigree.t.txt
    ```
    
    * input.gz is the one obtained from the previous step (example 06.posterior/post.gz)  
    * Edit the parameters in the scripts  
    * important parameters for filtering are:
     * the minor allele frequency (MAF), 
     * the missing rate (missingLimit)
     * the tolerance level (tol)  
     
     
* **_4 Separate chromosomes:_**
  * script to use is: `00_scripts/04.separate_chromosome.sh`
  * important parameters are the following: 
    * the input file (from previous step, something like `07.lepmap/data_f.call_missXXX_tolYYY_MAFZZZ.gz`)  
    * *informativeMask* (either use markers informative for the male (1), female (2) or both (3)  
    * *distortionLod* use segregation distortion aware LOD scores  
    * *sizeLimit* remove LG group with less than the indicate numbers of markers
    * More details in the script  
   
* **_5 join single markers_**
  * script to use is: `00_scripts/05.join_single.sh` 
  * this will join marker not assigned to the previously formed linkage groups.
  * four input parameterss are required :
   	* 1- the filtered posterior data file
   	* 2- the map created from the previous step
   	* 3- A minimal LOD score
   	* 4- A lod difference
   * Other important parameters include recombination rate in male and femal or overall
   * I used the iterate=1 so that the script will iterate until no markers can be added to the LG.
   
 * **_6 order the markers_**
 * script to use is: `00_scripts/06.order_marker.sh`
  * this will order markers in each LG separately and then evaluate the order through 5 repetition (this can be incrased).  
  * two input parameterss are required :
    * the filtered posterior data file  
    * the map from the previous steps (join_single.sh) 
 	  * see other details in the script. 
 	
  
* **_7 the map can then be visualized in R or reshaped for MapComp_**  

To fill  

* **_8 reshaping for r/QTL_**  

  * Convert to genotypes:
  
```bash
folder=$1
#example: folder=10.ordered_evaluated_map_miss0.20_tol0.0001_single.iterated_lodLimit4LodDiff2.txt

map=$2
awk '{print $1}' $map |sort |uniq -c |sort -k 2 -n |sed 1,2d |awk '{print $2}'  > chromolist

for i in $(cat chromolist ) ; do 
    grep "likelihood" $folder/*/order_evaluated_LG$i.txt |\
        sed 's/:\#\*\*\* LG = 0 likelihood = /\t/g' |\
        cut -d "/" -f 2- |\
        sed 's/\//\t/g' >> likelihood.list;
done

sort -k2,2n -k3,3g likelihood.list |awk '!a[$2] {a[$2] = $3} $3 == a[$2]' |awk '!seen[$2,$3]++' > wanted.run.txt
cut -f 1,2 wanted.run.txt |sed 's/\t/\//g'  > file

mkdir 11.map/
for i in $(cat file ) ; do cp $folder/$i 11.map/ ; done

#recover CHR\tPOS id 
zcat 07_lepmap/data_f.call_miss0.20_tol0.0001_MAF0.05.gz | cut -f 1,2|awk '(NR>=7)' >snps.txt

mkdir 12.map_with_pos
mkdir 13.genotype_map
mkdir 14.rqtl_analysis

for i in $(cat chromolist ) ;
do  
    #insert snp id
    awk -vFS="\t" -vOFS="\t" '(NR==FNR){s[NR-1]=$0}(NR!=FNR){if ($1 in s) $1=s[$1];print}' \
      snps.txt 11.map/order_evaluated_LG$i.txt >   12.map_with_pos/order.map.LG$i.txt ; 
    
    #insert LG to explore data
    grep -v "#" 12.map_with_pos/order.map.LG$i.txt |\
      sed "s/^/$i\t/g" >> 12.map_with_pos/map.all.LG.txt ; 
    
    #convert data to genotype for QTL analysis
    awk -vfullData=1 -f 00_scripts/awk_scripts/map2genotypes.awk \
      11.map/order_evaluated_LG$i.txt >13.genotype_map/map.data.LG$i.12.txt

    #then insert LG number
    awk -v var=$i 'BEGIN{FS=OFS="\t"} $2=="0"{$2=var} 1' 13.genotype_map/map.data.LG$i.12.txt > 13.genotype_map/map.reshape.$i.txt ; done 
    rm 13.genotype_map/map.dat.LG$i.12.txt
    
    #reshape to match rqtl requirement 
    sed 's/1 1/A/g' 13.genotype_map/map.reshape.$i.txt |\
    sed 's/2 2/B/g' |sed 's/2 1/H/g' |sed 's/1 2/H/g' > 14.rqtl_analysis/data.LG$i.txt ; 

    #only print wanted column and remove female recombination as it is zero in our case
      awk '(NR>6)' 14.rqtl_analysis/data.LG$i.txt |cut -f 1-3,5 >> data.tmp
 done
 
 00_scripts/awk_scripts/transpose_tab data.tmp > data.tmp2
 paste indiviuals.id phenotype data.tmp2 |sed 's/\t/,/g' > data.csv
 
 
 
 
```
 
  * Reshape the genotype matrix for R/qtl   
  
 To fill
