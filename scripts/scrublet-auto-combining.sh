
#scrublet-auto-combining.sh
#must be run in conda environment containg python3.9, pandas, numpy, scipy.io, matplotlib, random, sklearn.cluster
#Example command call: bash /diskmnt/Projects/Users/austins2/tools/scrublet-auto-combining.sh /diskmnt/Projects/Users/austins2/tools/automated_scrublet/scripts /diskmnt/Projects/PDX_scRNA_analysis/matching_snRNAseq/PDAC/cellranger-arc2 /diskmnt/Projects/PDX_scRNA_analysis/matching_snRNAseq/PDAC/scrubletv3-RNA/kmeans-testing/RNA-auto /diskmnt/Projects/PDX_scRNA_analysis/matching_snRNAseq/PDAC/scrubletv3-RNA/kmeans-testing/ATAC-auto
#file structure for when command is run:
#incoming-path/
            # /cellranger #provide the fullpath here
            #            /Sample-1
            #                     /outs
            #            /sample-2
            #                     /outs
            #            /3rd-sample
            #                       /outs
            # /scrublet #this directory can actually be anywhere you want it to be so long as it exists. It also can be named something else. provide the full path here second
            #            /Sample-1
            #                     /Sample-1_scrublet_output_table.csv
            #            /sample-2
            #                     /sample-2_scrublet_output_table.csv
            #            /3rd-sample
            #                       /3rd-sample_scrublet_output_table.csv
#
folder=$(pwd)
scrublet=$1
cellrangerpath=$2
scrubletATAC=$4
scrubletRNA=$3
outdir=$5
for dir in $cellrangerpath/*; do
    dir=${dir%*/}
    dir="${dir##*/}"
    if [ -d "$cellrangerpath"/"$dir" ]
    then
        echo $dir
        if [ -d "$cellrangerpath"/"$dir"/outs ]
        then
            echo "Cellranger for $dir exists"
            mkdir $outdir/$dir
            cd $outdir/$dir
            python3 $scrublet/combining-sn-and-atac-scrublet.py -s $dir --rna_input $scrubletRNA --atac_input $scrubletATAC $outdir
            cd $folder
        else
            echo "Cellranger outs for $dir does not exist at the provided location"
        fi
    fi
done

