#!/bin/bash
CLASSPATH=/Volumes/PromiseDisk/Desktop/java/picard_GATK
tempSpillFolder=~/Desktop/tmpFolder

InputFolder=../Mapping/BAM
OutputFolder=./combinedVCFs
mkdir -p $OutputFolder

GenomeReference=/Volumes/PromiseDisk/GATK_ref/hg19.fasta
GenomeInterval=/Volumes/PromiseDisk/GATK_ref/Agilent_S03723314_Covered.bed  # Narrow the GATK search restricted to this interval for faster speed


while read line; do
	tumorVCF=$(echo $line | awk '{print $1}')
	normalVCF=$(echo $line | awk '{print $2}')
	echo "normal file is $normalVCF, tumor file is $tumorVCF"

	tumorfilename1=$(basename "$tumorVCF")
	tumorfilename2="${tumorfilename1%%.*}"
	
	normalfilename1=$(basename "$normalVCF")
	normalfilename2="${normalfilename1%%.*}"


java -Xmx10g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
-R $GenomeReference \
-T CombineVariants \
--variant:tumor $tumorVCF \
--variant:normal $normalVCF \
-genotypeMergeOptions PRIORITIZE \
-priority tumor,normal \
-o $OutputFolder/$tumorfilename2.$normalfilename2.combined.vcf


done < VCFfiles.list 
