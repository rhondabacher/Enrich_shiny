# Enrich_shiny
R/shiny app for enrichment analysis

## Installation
This app requires the following packages : shiny, shinyFiles, org.Hs.eg.db, org.Mm.eg.db, GO.db, allez, EACI

To install shiny and db packages, in R run:

> install.packages('shiny')

> install.packages('shinyFiles')

> install.packages('devtools')

> install.packages('DT')

> if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
    
> BiocManager::install('org.Hs.eg.db')

> BiocManager::install('org.Mm.eg.db')

> BiocManager::install('GO.db')

> library(devtools)

> install_github('lengning/allez')

> install_github('lengning/EACI/package/EACI')

Note: allez and EACI could also be found locally at https://github.com/lengning/Enrichment-test/tree/master/pkgs

## Run the app

In R, run:

> library(shiny)

> library(shinyFiles)

> library(DT)

> runGitHub("rhondabacher/Enrich_shiny")

![screen](https://github.com/lengning/Enrich_shiny/blob/master/figs/enrich_screenshot.png)

## Input

The input file should contain gene scores. The score could be either continuous or binary (1 for on and 0 for off).
If continouse input is provided, it is suggested to convert the gene scores to z scores. The program will consider genes with highest score as significant if one sided test is specified (If two sided test is specified, the program will consider genes with highest absolute score as significant). 
Note for EASE method, only binary scores could be used as input.
The input file should contain only one column. Row names should be gene names. Each entry represents loading (or score) 
of that particular gene.
Currently the program takes csv files or tab delimited file.
The input file will be treated as a tab delimited file if the suffix is not '.csv'.
Example input files could be found at https://github.com/lengning/Enrich_shiny/tree/master/example_input   (Exampleloadings)

The second input button could be used to input the marker lists of interest. It could be csv or tab delimited file. Each row represents a marker list. 
Row names are the list names. The number of columns should be N, in which N is the number of genes in the longest list. 
For lists with length M - N, the M+1, ..., N's column in that row should be filled with "" or " ". If the local marker list
is not specified, only GO terms will be considered. 
Example input files could be found at https://github.com/lengning/Enrich_shiny/tree/master/example_input   (MarkerLists)

The threshold to filter out small(large) sets defaults to 5 (500). Sets that are smaller (larger) than the threshold are not considered.

The annotation could be either 'human' or 'mouse'. The p value cutoff defaults to 0.1.

The user could also choose whether one-tailed p value should be calculated. If the input values are absolute values, then it should be specified as "one-tailed". Otherwise it should be specified as "two-tailed", in which case two-tailed p values will be calculated. This option is only valid in the allez implementation (not in EACI or EASE).

The user could use the 'output folder' button to choose the output directory. If it is not selected, home directory (~/) will be used
as the output directory. 

## Output

XX_allsets.txt: enrichment results of all gene sets (GO sets + local sets). 

XX_allsets_significant.txt: significant terms; The summary statistics of these sets are the same as those in the XX_allsets.txt

XX_localsets.txt: enrichment results of only local sets. The summary statistics of these sets are the same as those in the XX_allsets.txt

XX_localsets_significant.txt: significant terms in local lists


The output files contain GO term (NA for local sets), set p value, adjusted p value, z score, set size, set mean and set sd. Sets are sorted by p value. Sets with large absoloute z scores are expected to have small p values.


## Note

The 'create new folder' button in the output folder selection pop-up is disfunctional right now


## Trouble shooting
When running runGitHub() function, if you get a download error as shown below, please create a empty directoy locally and download server.R and ui.R into this local directory, then run the following command in R: 

> runApp("your_local_directory_which_contains_the_2_files")


Example error msg:

> runGitHub("lengning/Enrich_shiny")

> Downloading https://github.com/lengning/Enrich_shiny/archive/master.tar.gz

> Error in runUrl(url, subdir = subdir, destdir = destdir, ...) :

>   Failed to download URL https://github.com/lengning/Enrich_shiny/archive/master.tar.gz

> In addition: Warning message:

> In download.file(url, method = method, ...) :

>   download had nonzero exit status
  
Alternative solution: Uninstalling wget fixed this issue.
