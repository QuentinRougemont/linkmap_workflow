# linkmap_workflow

# purpose:

constructing linkage map based on LepMap3 
Tested with F1 crosses on lampreys and apollo parnasius 


# Depandancies: 
   * Lepmap3 software available [here](https://sourceforge.net/p/lep-map3/code/ci/master/tree/)
   * download it and add the path to your bashrc
   * For alignment [bwa mem]((https://sourceforge.net/projects/bio-bwa/files/) and [samtools](http://www.htslib.org) are required      
    


# **MAJOR STEPS:** 

 * **_1 preliminary step: alignment (and eventually SNP calling)_**
        * Use **bwa** to align the data (see e.g. [this for RADseq](https://github.com/QuentinRougemont/stacks_v2_workflow/blob/master/00-scripts/04.bwa_mem_align_reads_pe.sh)  
          

 * **_2 convert bam to posterior_**
        * simply use the scripts provided with LepMap: pileup2likelihood:
 
        ```
        samtools mpileup -q 20 -Q 20 -s $(cat list_sorted_bam.txt)|\
        java -cp bin/ Pileup2Likelihoods|\
        gzip >post.gz  
        
        Alternatively use the script:
        00.scripts/01.mpileup_to_posterior.sh
        ```

* **_3 run parentCall and filter the data:_**
    * script to use is: `00.scripts/02.parentcall_and_Filtering.sh` 
    * important parameters for filtering are:
     * the minor allele frequency (MAF), 
     * the missing rate (missingLimit)
     * the tolerance level (tol)  
     
* **_4 Separate chromosomes:_**
  * script to use is: `00.scripts/03.separate_chromose.sh`
  * important parameters are the following:
    * *informativeMask* (either use markers informative for the male (1), female (2) or both (3)
    * *distortionLod* use segregation distortion aware LOD scores 
    * *sizeLimit* remove LG group with less than the indicate numbers of markers
    * More details in the script  
   
* **5_join single markers_**
  * script to use is: `00.scripts/04.join_single.sh`
  * important parameters are :
   	* the input file
   	* A minimal LOD score
   	* A lod difference
   * More details are in the script
   
 * **6_order the markers_**
 * script to use is: `00.scripts/05.order_marker.sh`
 	* see details in the script. Several iterations needs to be performed.
 	
* **7_the map can then be visualized in R or reshaped for MapComp**

