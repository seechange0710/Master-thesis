# what this repository about?
The primary goal of this repository is to deposit the codes used in preprocessing steps of bulk RNA-seq analysis on model plant _A. thaliana_ and rape seed _B. napus_ in my master thesis, as well as for sharing and demonstrating purposes.

# what steps are included in raw-data preprocessing?
As indicated by the name of my code files, the raw-data preprocessing includes five main steps: 
<br /> **1. Read filtering/cleaning (Quality filtering + Adapter contamination cleaning)** --> file 0-3 
<br /> **2. Alignment of filtered reads to genomic features** --> file 4 
<br /> **3. Quantification of read count** --> file 5&6
<br /> **4. Raw-data processing steps were further integrated and automated through Nextflow pipeline** --> folder 'Nextflow_pipeline' 