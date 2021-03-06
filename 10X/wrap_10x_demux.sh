#! /bin/bash

# Run without "os" flag
# To add os flag:
# #$ -l os=RedHat6
# bcl2fastq should work on both OSes

#$ -cwd
#$ -P regevlab
#$ -l h_vmem=8g
#$ -e demux.err
#$ -o demux.log
#$ -l h_rt=30:00:00

source /broad/software/scripts/useuse
reuse UGER
use .bcl2fastq2-2.20.0.422 # RedHat6
use .bcl2fastq2-v2.20.0 # RedHat7
export PATH=/seq/regev_genome_portal/SOFTWARE/10X/cellranger-VERSION:$PATH
cellranger mkfastq --run=INDIR --csv CSV --jobmode=/home/unix/csmillie/code/10X/sge.template
