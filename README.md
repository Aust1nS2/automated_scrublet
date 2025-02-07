# automated_scrublet
 Automating the running of scrublet and doublet thresholding for snRNA-seq and/or snATAC-seq data from Cellranger

Scrublet is a tool for doublet detection in single cell and snRNA data.
The tool was originally published here:
<https://doi.org/10.1016/j.cels.2018.11.005>. When using it you are
supposed to run it and then manually decide on a threshold for calling
doublets after evaluating the results. I incorporated it into a script
and then use kmeans clustering for automated detection of an appropriate
cutoff. This cutoff is then used to label cells as doublets or singlets.
It is strongly recommended that you use it or some other version of
doublet detection on your scRNA-seq, snRNA-seq, snATAC-seq, or multiome
data. One caveat of most doublet detection methods (including scrublet)
is that they work by combining the counts data of different cells to
simulate doublets. These simulated doublets are then assign a confidence
score to cells in the dataset based on how similar the cells of the
dataset are to the simulated doublets. The problem with this approach is
that if you are working with a dataset where you have populations
transitioning from one cell type to another (as is common during tissue
renewal or development), then these populations are more likely to be
called as doublets by scrublet and other doublet detection methods.
These would be considered false positives. As a result I recommend using
scrublet to intially call doublets and then waiting to actually remove
them until you are able to start analyzing your data. While doing so you
should be mindful of if any cell types that could be transitional
populations and if there is any evidence in the current body of
literature or other good reason to support the existence of a
transitional population in your dataset. Once you have annotated your
dataset and are confident where the doublets are then you should remove
them, re-normalize/re-integrate the merged object, and assign cell types
on the cleaned object. This is how we ran scrublet in this publication
<https://doi.org/10.1038/s41586-023-06682-5> so if you are looking for
methods paragraphs go look there.

# Setup and input

The environment that is used for doublet detection is found here:
```
    environments/py3.9_spec_file.20250206.txt
```
You can install the environment for your use via the following commands:
```
    conda create -n scrublet --file ./environments/py3.9_spec_file.20250206.txt
```
If you have trouble installing the environment with any of the provided environment files you can view which libraries are used in the python script and install them via conda

Scrublet should always be used on the filtered matrix results from
cellranger, cellranger-atac, or cellranger-arc. In theory it could be
used on the raw results however, when I have attempted to put this into
practice for a single sample it ran for over a week before I gave up on
it. If you wanted to generate a seurat object first and then filter
based on your desired counts cutoffs, you could then save the results to
a matrix in a similar format to that of the cellranger output which
scrublet could then use as input. The results could then be attached to
the already generated seurat object. I have not done this yet.

I have written a python script and a wrapper script for each use case
snRNA/scRNA, snATAC, and multiome. If you are working with just a single
sample then feel free to use just the python script for your doublet
calling. If you are working with multiple samples then it is easiest to
use the wrapper shell scripts that call the python scripts. Each of them
are listed in their respective sections below. Feel free to create your
own copies and modify as necessary.

If you are going to use the wrapper scripts I have already set-up then
your input is the path to a directory that contains one or more
cellranger run folders. These can be softlinks to cellranger run
folders. The wrapper script will name the output folders based on the
name of the cellranger run folders in the input folder. An example is
below:
```
    # If your input folder looks like this:
    /path/to/input/directory/
                            |
                            |
                            Sample_1/
                            |
                            Sample_2/
                            |
                            Sample_3/
    # Sample_1 and Sample_2 could be the actual cellranger run folder
    # Sample_3 could then be a softlink to another cellranger run folder
    # then the output of the scrublet wrapper scripts as I have written them will be:
    /path/to/directory/where/scrublet/wrapper/script/is/executed/
                                                                |
                                                                |
                                                                Sample_1/
                                                                |
                                                                Sample_2/
                                                                |
                                                                Sample_3/
```
The memory requirements are relatively small for single cell analysis at
around 10GB-20GB per scrublet run. However, it will intermittently
utilize a very high number of CPU threads. You can probably start 4-6
separate instances of the scrublet script before it utilizes nearly all
of the CPU cores at 100% on a node with 96 threads constantly.

# Running on scRNA/snRNA data

## Scripts

The input of this is the output of running cellranger. The scripts used
for running automated scrublet doublet detection are:
```
    scrublet-RNA-auto.sh
    scrublet-comboRNA-auto.py
```
## Example run

When the script is called it will write the output to the directory that
you are currently in so cd into that directory first

Run commands:
```
    cd /path/to/the/scrublet/folder/
    bash scrublet-RNA-auto.sh /path/to/install/of/automated_scrublet/scripts /path/to/folder/with/cellranger-runs/
```
Example run:
```
    cd /diskmnt/Projects/Users/austins2/pdac/primary_tumor/sn/scrublet-snRNA/2022-11-08/
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-RNA-auto.sh /diskmnt/Projects/Users/austins2/tools/automated_scrublet/scripts /diskmnt/Projects/HTAN_analysis_2/Cellranger/snRNA_of_multiome/2022-11-08/
```
## Example output

There are 5 files that will be generated as output for each sample that
is listed in the input directory:
```
    /scrublet/run/directory/
                            |
                            |
                            Sample_1/
                                    |
                                    Sample_1_doublets_hist.pdf
                                    |
                                    Sample_1_doublets_umap.pdf
                                    |
                                    Sample_1_scrublet_cutoff_.txt
                                    |
                                    Sample_1_scrublet_output_table.csv
                                    |
                                    Sample_1_scrublet_simulated_doublet_scores_table.csv
```
-   `Sample_1_doublets_hist.pdf` - This a histogram of the doublet scores
    for each cell as predicted by scrublet. Higher means the cell is
    more likely to be a doublet. The vertical line is at the value of
    the final doublet cutoff that was used for this sample. This is
    generated on a per sample basis. This part is the most helpful for
    actually evaluating how well it worked.
-   `Sample_1_doublets_umap.pdf` - This is a UMAP of the sample that
    doublet scores were calculated for where dot color represents the
    scrublet doublet score.
-   `Sample_1_scrublet_cutoff_.txt` - Scrublet is run on each sample 10
    times and the mean doublet score cutoff found by kmeans clustering
    of each of those runs is used as the final doublet score cutoff
    value. Usually this is pretty consistent. The final cutoff value is
    the one listed at the bottom of the text file.
-   `Sample_1_scrublet_output_table.csv` - This is a csv file with 3
    columns. The first column is the cell barcode. The second column is
    the mean doublet score for that cell across all 10 runs. The third
    column is the final doublet prediction for that cell. `False` means
    that cell was predicted to not be a doublet. `True` means that cell
    was predicted to be a doublet.
-   `Sample_1_scrublet_simulated_doublet_scores_table.csv` - this is a csv
    file where the simulated doublet score for each cell is recorded
    from every scrublet iteration.

Because we rely on the filtered matrix found in the
`/outs/filtered_feature_bc_matrix/` folder from a cellranger run as
input for scrublet there will be some cells that may be present in the
seurat object that are otherwise missing from the scrublet run. When you
add the scrublet information to the seurat object metadata these cells
will have `NA` values. When filtering merged/integrated datasets we only
remove cells marked as `True` in the predicted_doublet metadata column.
If a cell is marked as `False` or `NA` then we do not necessarily filter
it based solely on doublet status in the metadata.

Here is an example of how to add scrublet output to a seurat object's
metadata.
```
    scrublet.path <- paste0("/path/to/scrublet/output/folder/",sample_id,"/",sample_id,"_scrublet_output_table.csv")
    scrublet.df <- read.table(file = scrublet.path, sep=",", header = TRUE, row.names = "Barcodes")
    seurat.obj <- AddMetaData(object = seurat.obj, metadata = scrublet.df)
```
Values will be saved to the seurat object columns called `doublet_score`
and `predicted_doublet`

# Running on snATA data

## Scripts

The input of this is the output of cellranger-atac. The scripts used for
running automated scrublet doublet detection are:
```
    /diskmnt/Projects/Users/austins2/tools/scrublet-ATAC-only-auto.sh
    /diskmnt/Projects/Users/austins2/tools/scrublet-ATAC-only-auto.py
```
## Example run

When the script is called it will write the output to the directory.

Run commands:
```
    cd /path/to/the/scrublet/folder/
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-ATAC-only-auto.sh /path/to/install/of/automated_scrublet/scripts /path/to/folder/with/cellranger-atac-runs/
```
Example run:
```
    cd /diskmnt/Projects/Users/austins2/pancan_ATAC/separate-cellranger-test/scrublet
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-ATAC-only-auto.sh /diskmnt/Projects/Users/austins2/tools/automated_scrublet/scripts /diskmnt/Projects/Users/austins2/pancan_ATAC/separate-cellranger-test/ATAC/
```
## Example output

There are 5 files that will be generated as output for each sample that
is listed in the input directory:
```
    /scrublet/run/directory/
                            |
                            |
                            Sample_1/
                                    |
                                    Sample_1_doublets_hist.pdf
                                    |
                                    Sample_1_doublets_umap.pdf
                                    |
                                    Sample_1_scrublet_cutoff_.txt
                                    |
                                    Sample_1_scrublet_output_table.csv
                                    |
                                    Sample_1_scrublet_simulated_doublet_scores_table.csv
```
-   `Sample_1_doublets_hist.pdf` - This a histogram of the doublet scores
    for each cell as predicted by scrublet. Higher means the cell is
    more likely to be a doublet. The vertical line is at the value of
    the final doublet cutoff that was used for this sample. This is
    generated on a per sample basis. This part is the most helpful for
    actually evaluating how well it worked.
-   `Sample_1_doublets_umap.pdf` - This is a UMAP of the sample that
    doublet scores were calculated for where dot color represents the
    scrublet doublet score.
-   `Sample_1_scrublet_cutoff_.txt` - Scrublet is run on each sample 10
    times and the mean doublet score cutoff found by kmeans clustering
    of each of those runs is used as the final doublet score cutoff
    value. Usually this is pretty consistent. The final cutoff value is
    the one listed at the bottom of the text file.
-   `Sample_1_scrublet_output_table.csv` - This is a csv file with 3
    columns. The first column is the cell barcode. The second column is
    the mean doublet score for that cell across all 10 runs. The third
    column is the final doublet prediction for that cell. `False` means
    that cell was predicted to not be a doublet. `True` means that cell
    was predicted to be a doublet.
-   `Sample_1_scrublet_simulated_doublet_scores_table.csv` - this is a csv
    file where the simulated doublet score for each cell is recorded
    from every scrublet iteration.

Because we rely on the filtered matrix found in the
`/outs/filtered_feature_bc_matrix/` folder from a cellranger run as
input for scrublet there will be some cells that may be present in the
seurat object that are otherwise missing from the scrublet run. When you
add the scrublet information to the seurat object metadata these cells
will have `NA` values. When filtering merged/integrated datasets we only
remove cells marked as `True` in the predicted_doublet metadata column.
If a cell is marked as `False` or `NA` then we do not necessarily filter
it based solely on doublet status in the metadata.

Here is an example of how to add scrublet output to a seurat object\'s
metadata.
```
    scrublet.path <- paste0("/path/to/scrublet/output/folder/",sample_id,"/",sample_id,"_scrublet_output_table.csv")
    scrublet.df <- read.table(file = scrublet.path, sep=",", header = TRUE, row.names = "Barcodes")
    seurat.obj <- AddMetaData(object = seurat.obj, metadata = scrublet.df)
```
Values will be saved to the seurat object columns called `doublet_score`
and `predicted_doublet`

An example output folder can be found at
`/diskmnt/Projects/Users/austins2/pancan_ATAC/separate-cellranger-test/scrublet/CPT1541DU-S1/`

# Running on multiome data

The input of this is the output of cellranger-arc If you just want to
use the RNA part of a multiome sample then only use the RNA output from
the below commands. If you just want to use the ATAC output then just
use the ATAC part of the below commands. The scripts used for running
automated scrublet doublet detection are:
```
    /diskmnt/Projects/Users/austins2/tools/scrublet-ATAC-auto.sh
    /diskmnt/Projects/Users/austins2/tools/scrublet-comboATAC-auto.py
    /diskmnt/Projects/Users/austins2/tools/scrublet-RNA-auto.sh
    /diskmnt/Projects/Users/austins2/tools/scrublet-comboRNA-auto.py
    /diskmnt/Projects/Users/austins2/tools/scrublet-auto-combining.sh
    /diskmnt/Projects/Users/austins2/tools/combining-sn-and-atac-scrublet.py
```
## Example run

When the script is called it will write the output to the directory in
which it is called.

You will need to run the RNA part and the ATAC parts separately. After
they are both done you can combine them into a a single result file. I
recommend setting up three separate folders. One for the RNA results.
One for the ATAC results. One for the result of combining them. The
outputs of both are used to inform doublet calls in Seurat/Scanpy.

Run commands:
```
    cd /path/to/the/scrublet_folder/RNA/
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-RNA-auto.sh /path/to/install/of/automated_scrublet/scripts /path/to/folder/with/cellranger-arc-runs/
    cd /path/to/the/scrublet_folder/ATAC/
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-ATAC-auto.sh /path/to/install/of/automated_scrublet/scripts /path/to/folder/with/cellranger-arc-runs/
    cd /path/to/the/scrublet_folder/combined/
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-auto-combining.sh /path/to/install/of/automated_scrublet/scripts /path/to/folder/with/cellranger-arc-runs/ /path/to/the/scrublet_folder/RNA/ /path/to/the/scrublet_folder/ATAC/
```
Example run:
```
    conda activate py3.9
    cd /diskmnt/Projects/HTAN_analysis_2/PDAC/primary/sn/scrublet-arc/20231030/RNA
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-RNA-auto.sh /diskmnt/Projects/Users/austins2/tools/automated_scrublet/scripts /diskmnt/Projects/HTAN_analysis_2/Cellranger-arc/20231030
    cd /diskmnt/Projects/HTAN_analysis_2/PDAC/primary/sn/scrublet-arc/20231030/ATAC
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-ATAC-auto.sh /diskmnt/Projects/Users/austins2/tools/automated_scrublet/scripts /diskmnt/Projects/HTAN_analysis_2/Cellranger-arc/20231030
    cd /diskmnt/Projects/HTAN_analysis_2/PDAC/primary/sn/scrublet-arc/20231030/combined
    bash /diskmnt/Projects/Users/austins2/tools/scrublet-auto-combining.sh /diskmnt/Projects/Users/austins2/tools/automated_scrublet/scripts /diskmnt/Projects/HTAN_analysis_2/Cellranger-arc/20231030/ /diskmnt/Projects/HTAN_analysis_2/PDAC/primary/sn/scrublet-arc/20231030/RNA/ /diskmnt/Projects/HTAN_analysis_2/PDAC/primary/sn/scrublet-arc/20231030/ATAC/
```
## Example output

There are 5 files that will be generated as output for each sample that
is listed in the input directory:
```
    /scrublet/run/directory/RNA/
                            |   |
                            |   |
                            |    Sample_1/
                            |            |
                            |            Sample_1_doublets_hist.pdf
                            |            |
                            |            Sample_1_doublets_umap.pdf
                            |            |
                            |            Sample_1_scrublet_cutoff_.txt
                            |            |
                            |            Sample_1_scrublet_output_table.csv
                            |            |
                            |            Sample_1_scrublet_simulated_doublet_scores_table.csv
                            ATAC/
                            |    |
                            |    |
                            |    Sample_1/
                            |            |
                            |            Sample_1_doublets_hist.pdf
                            |            |
                            |            Sample_1_doublets_umap.pdf
                            |            |
                            |            Sample_1_scrublet_cutoff_.txt
                            |            |
                            |            Sample_1_scrublet_output_table.csv
                            |            |
                            |            Sample_1_scrublet_simulated_doublet_scores_table.csv
                            combined/
                                    |
                                    |
                                    Sample_1/
                                            |
                                            Sample_1_combo_scrublet_output_table.csv
```
For each sample the RNA and ATAC folders will each have the following 5
files (they are basically the same as when you run it just on snRNA or
just snATAC):

-   `Sample_1_doublets_hist.pdf` - This a histogram of the doublet
    scores for each cell as predicted by scrublet. Higher means the cell
    is more likely to be a doublet. The vertical line is at the value of
    the final doublet cutoff that was used for this sample. This is
    generated on a per sample basis.
-   `Sample_1_doublets_umap.pdf` - This is a UMAP of the sample that
    doublet scores were calculated for where dot color represents the
    scrublet doublet score.
-   `Sample_1_scrublet_cutoff_.txt` - Scrublet is run on each sample 10
    times and the mean doublet score cutoff found by kmeans clustering
    of each of those runs is used as the final doublet score cutoff
    value. Usually this is pretty consistent. The final cutoff value is
    the one listed at the bottom of the text file.
-   `Sample_1_scrublet_output_table.csv` - This is a csv file with 3
    columns. The first column is the cell barcode. The second column is
    the mean doublet score for that cell across all 10 runs. The third
    column is the final doublet prediction for that cell. `False` means
    that cell was predicted to not be a doublet. `True` means that cell
    was predicted to be a doublet.
-   `Sample_1_scrublet_simulated_doublet_scores_table.csv` - This is a
    csv file where the simulated doublet score for each cell is recorded
    from every scrublet iteration.

In addition there will be one file per sample in the combined output
folder:

-   `Sample_1_combo_scrublet_output_table.csv` - This is a csv file with
    5 columns.
    -   Column 1 is the cell barcode
    -   Column 2 is the `doublet_score_rna` which is the doublet score
        from the RNA part of the scrublet run (comes from
        `./RNA/Sample_1/Sample_1_scrublet_output_table.csv`).
    -   Column 3 is the `predicted_doublet_rna` which is the doublet
        prediction for that cell from the RNA part of the scrublet run
        (comes from
        `./RNA/Sample_1/Sample_1_scrublet_output_table.csv`).
    -   Column 4 is the `doublet_score_atac` which is the doublet score
        from the ATAC part of the scrublet run (comes from
        `./ATAC/Sample_1/Sample_1_scrublet_output_table.csv`).
    -   Column 5 is the `predicted_doublet_atac` which is the doublet
        prediction for that cell from the ATAC part of the scrublet run
        (comes from
        `./ATAC/Sample_1/Sample_1_scrublet_output_table.csv`).

Because we rely on the filtered matrix found in the
`/outs/filtered_feature_bc_matrix/` folder from a cellranger run as
input for scrublet there will be some cells that may be present in the
seurat object that are otherwise missing from the scrublet run. When you
add the scrublet information to the seurat object metadata these cells
will have `NA` values. When filtering merged/integrated datasets we only
remove cells marked as `True` in the predicted_doublet metadata column.
If a cell is marked as `False` or `NA` then we do not necessarily filter
it based solely on doublet status in the metadata.

Here is an example of how to add multiome scrublet output to a seurat
object\'s metadata.
```
    scrublet.path <- paste0("/path/to/scrublet/output/folder/combined/",sample_id,"/",sample_id,"_combo_scrublet_output_table.csv")
    scrublet.df <- read.table(file = scrublet.path, sep=",", header = TRUE, row.names = "Barcodes")
    scrublet.df$predicted_doublet <- "NA"
    scrublet.df$predicted_doublet[scrublet.df$predicted_doublet_rna == 'True' & scrublet.df$predicted_doublet_atac == 'True'] <- 'True'
    scrublet.df$predicted_doublet[scrublet.df$predicted_doublet_rna == 'False' | scrublet.df$predicted_doublet_atac == 'False'] <- 'False'
    seurat.obj <- AddMetaData(object = seurat.obj, metadata = scrublet.df)
```
Values will be saved to the seurat object columns called `doublet_score`
and `predicted_doublet`

An example output folder can be found at
`/diskmnt/Projects/HTAN_analysis_2/PDAC/primary/sn/scrublet-arc/20231030/combined`
