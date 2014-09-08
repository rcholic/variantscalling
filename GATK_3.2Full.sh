#!/bin/bash

#-----------------Configuration----------------------------

CLASSPATH=/Library/Java/Extensions

GenomeReference=/Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta
GenomeInterval=/Volumes/tempdata1/tonywang/GATK_ref/Agilent_S03723314_Covered.bed  # Narrow the GATK search restricted to this interval for faster speed
knownSites1=/Volumes/tempdata1/tonywang/GATK_ref/dbsnp_137.hg19.vcf
knownSites2=/Volumes/tempdata1/tonywang/GATK_ref/Mills_and_1000G_gold_standard.indels.hg19.vcf
tempSpillFolder=/Volumes/tempdata1/tonywang/GATK_tmp      # temporary cache folder for GATK

InputFolder=./Mapping/BAM
OutputFolder=$InputFolder/BQSR
OutputVCFFolder=$InputFolder/VQSR
mkdir -p $OutputFolder
mkdir -p $OutputVCFFolder
#-----------------end of Configuration section---------------


# Now start GATK with the output of last PiCard step

for file in $InputFolder/*grp.bam; do

      filename=$(basename "$file")
      extension="${filename##*.}"
      sample="${filename%.*}"
echo $file
echo $sample

#use GATK to RealignerTarget Creator

java -Xmx10g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R $GenomeReference \
-I $file \
-L $GenomeInterval \
-o $OutputFolder/$sample.intervals

done

echo "now moving on to the next step"


for file in $InputFolder/*grp.bam; do

      filename=$(basename "$file")
      extension="${filename##*.}"
      sample="${filename%.*}"
echo $file
echo $sample

java -Xmx10g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T IndelRealigner \
-R $GenomeReference \
-I $file \
-L $GenomeInterval \
-targetIntervals $OutputFolder/$sample.intervals \
-o $OutputFolder/$sample.realigned.bam

done

for file in $OutputFolder/*realigned.bam; do

      filename=$(basename "$file")
      extension="${filename##*.}"      
      sample="${filename%.*}"
      echo $sample
      echo $file

java -Xmx10g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T BaseRecalibrator \
-R $GenomeReference \
-knownSites $knownSites1 \
-knownSites $knownSites2 \
-I $file \
-L $GenomeInterval \
-o $OutputFolder/$sample.recal.grp

done

echo "finished BaseRecalibrator"
echo "now moving to PrintReads"
echo "-------------------------------"



#GATK print reads step:

for file in $OutputFolder/*recal.grp; do

      filename=$(basename "$file")
      extension="${filename##*.}"
#      sample="${filename%%.*}"
      sample1="${filename%.*}"
      sample="${sample1%.*}"
      echo $sample
      echo $file

java -Xmx10g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T PrintReads \
-R $GenomeReference \
-I $OutputFolder/$sample.bam \
-BQSR $file \
-L $GenomeInterval \
-o $OutputFolder/$sample.recal.bam

done


#joint variant calling for SNPs and Indels
#java -Xmx10g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
#-T HaplotypeCaller \
#-nct 7 \
#-R $GenomeReference \
#-I ./bamFilesList.list \
#--dbsnp $knownSites1 \
#-L $GenomeInterval \
#-o $OutputVCFFolder/raw.snps.indels.vcf
