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

java -Xmx12g -Djava.awt.headless=true -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T ApplyRecalibration \
-R $GenomeReference \
-nt 5 \
--input $InputVCF \
-mode SNP \
--ts_filter_level 99.0 \
-recalFile $SNPsOutput/exome.snps.vcf.recal \
-tranchesFile $SNPsOutput/exome.snps.tranches \
-o $SNPsOutput/exome.snps.filtered.vcf


java -Xmx12g -Djava.awt.headless=true -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T ApplyRecalibration \
-R $GenomeReference \
-nt 5 \
--input $InputVCF \
-mode INDEL \
--ts_filter_level 99.0 \
-recalFile $IndelsOutput/exome.indels.vcf.recal \
-tranchesFile $IndelsOutput/exome.indels.tranches \
-o $IndelsOutput/exome.indels.filtered.vcf
