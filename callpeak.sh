#!/bin/bash
#
# callpeak.sh
# CHTC peak calling with macs2
# Usage: callpeak.sh <treatment> <control> <narrow or broad>

# mkdir
export HOME=$PWD
mkdir -p input output

# assign treatment to $1
# assign control to $2
treatment=$1
control=$2
setting=$3

# assign blacklist variable to filename of mm10 blacklist
blacklist=mm10-blacklist.v2.bed.gz
chromsizes=mm10.chrom.sizes.txt

# copy $treatment and $control from staging to input directory
cp /staging/jespina/$treatment input
cp /staging/jespina/$control input

# copy mm10 blacklist to input directory
cp /staging/jespina/$blacklist input
cp /staging/jespina/$chromsizes input

# get basename of treatment and assign to $samplename for naming output files
samplename=`basename $treatment _bowtie2_sorted_mkdup.bam`

# print names of treatment and control files to stdout
echo "Treatment" $treatment 
echo "Control " $control 

# run macs2 depending on $setting
if [ "$setting" == "broad" ]; then 
	macs2 callpeak -t input/$treatment -c input/$control \
	-f BAMPE -g mm\
	-n ${samplename} --broad -B \
	--outdir output 2> output/${samplename}_macs2.log
	
	fileext="broadPeak"
	
elif [ "$setting" == "narrow" ]; then
	macs2 callpeak -t input/$treatment -c input/$control \
	-f BAMPE -g mm\
	-n ${samplename} -B \
	--outdir output 2> output/${samplename}_macs2.log

	fileext="narrowPeak"
fi

# filter out blacklist regions
bedtools intersect -a input/${samplename}.${fileext} \
	-b input/$blacklist -v \
	> output/${samplename}_blacklist-filtered.${fileext}

# tar macs2 outputs and move to staging
cd output
tar -czvf ${samplename}_macs2.tar.gz ./
mv ${samplename}_macs2.tar.gz /staging/jespina
cd ~

# before script exits, remove files from working directory
rm -r input output

###END
