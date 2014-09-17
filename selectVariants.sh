#!/bin/bash
CLASSPATH=/Volumes/PromiseDisk/Desktop/java/picard_GATK
tempSpillFolder=~/Desktop/tmpFolder

InputFolder=../Mapping/BAM
OutputFolder=./combinedVCFs
mkdir -p $OutputFolder

GenomeReference=/Volumes/PromiseDisk/GATK_ref/hg19.fasta
GenomeInterval=/Volumes/PromiseDisk/GATK_ref/Agilent_S03723314_Covered.bed  # Narrow the GATK search restricted to this interval for faster speed

for file in ./combinedVCFs/*.vcf; do 
	echo $file 

	filename1=$(basename "$file")
	filename="${filename1%.*}"

java -Xmx10g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
-R $GenomeReference \
-T SelectVariants \
--variant $file \
-o $OutputFolder/$filename.selected.vcf \
-select 'set=="tumor"'

done
