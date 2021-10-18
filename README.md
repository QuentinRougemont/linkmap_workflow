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
        * An example script for bwa-mem can be find in `./00_scripts/00_bwa_mem.sh`
          * in this case trimmed reads should be store in a folder 04_data and the genome in 03_genome
          

 * **_2 convert bam to posterior_**
        * simply use the scripts provided with LepMap: pileup2likelihood:
 
        ```bash
        samtools mpileup -q 20 -Q 20 -s $(cat list_sorted_bam.txt)|\
        java -cp bin/ Pileup2Likelihoods|\
        gzip >post.gz  
        
        Alternatively use the script:
        00.scripts/06_posterior/01.mpileup_to_posterior.sh
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
    * the input file (from previous step, someting like 07.lepmap/data_f.call_missXXX_tolYYY_MAFZZZ.gz)  
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

