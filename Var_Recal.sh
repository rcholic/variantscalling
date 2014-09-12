#!/bin/bash
CLASSPATH=/Volumes/PromiseDisk/Desktop/java/picard_GATK
tempSpillFolder=~/Desktop/tmpFolder


GenomeReference=/Volumes/PromiseDisk/GATK_ref/hg19.fasta
GenomeInterval=/Volumes/PromiseDisk/GATK_ref/Agilent_S03723314_Covered.bed  # Narrow the GATK search restricted to this interval for faster speed

knownSites1=/Volumes/PromiseDisk/GATK_ref/dbsnp_137.hg19.vcf    
knownSites2=/Volumes/PromiseDisk/GATK_ref/Mills_and_1000G_gold_standard.indels.hg19.vcf

resource1=/Volumes/PromiseDisk/GATK_ref/Mills_and_1000G_gold_standard.indels.hg19.vcf
resource2=/Volumes/PromiseDisk/GATK_ref/dbsnp_137.hg19.vcf
resource3=/Volumes/PromiseDisk/GATK_ref/hapmap_3.3.hg19.vcf
resource4=/Volumes/PromiseDisk/GATK_ref/1000G_omni2.5.hg19.vcf
resource5=/Volumes/PromiseDisk/GATK_ref/1000G_phase1.snps.high_confidence.hg19.vcf
resource6=/Volumes/PromiseDisk/GATK_ref/dbsnp_137.hg19.vcf

dir=../Mapping/BAM/VQSR
InputVCF=$dir/New.raw.snps.indels.vcf
SNPsOutput=$dir/SNPs
IndelsOutput=$dir/Indels
mkdir -p $SNPsOutput
mkdir -p $IndelsOutput






java -Xmx8g -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T VariantRecalibrator \
-R $GenomeReference \
-input $InputVCF \
-nt 6 \
-resource:mills,known=true,training=true,truth=true,prior=12.0 $resource1 \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $resource2 \
-an QD -an HaplotypeScore -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an InbreedingCoeff \
--maxGaussians 8 \
-mode INDEL \
-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
-log $IndelsOutput/Indels.log \
-recalFile $IndelsOutput/exome.indels.vcf.recal \
-tranchesFile $IndelsOutput/exome.indels.tranches \
-rscriptFile $IndelsOutput/exome.indels.recal.plots.R




#java -Xmx8g -jar $CLASSPATH/GenomeAnalysisTK.jar \
#-T VariantRecalibrator \
#-R $GenomeReference \
#-input $InputVCF \
#-nt 8 \
#-resource:hapmap,known=false,training=true,truth=true,prior=15.0 $resource3 \
#-resource:omni,known=false,training=true,truth=true,prior=12.0 $resource4 \
#-resource:1000G,known=false,training=true,truth=false,prior=10.0 $resource5 \
#-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $resource6 \
#-an DP -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ \
#--maxGaussians 8 \
#-mode SNP \
#-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
#-log $SNPsOutput/Snps.log \
#-recalFile $SNPsOutput/exome.snps.vcf.recal \
#-tranchesFile $SNPsOutput/exome.snps.tranches \
#-rscriptFile $SNPsOutput/exome.snps.recal.plots.R
