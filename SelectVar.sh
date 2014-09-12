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


java -Xmx12g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $GenomeReference \
-nt 5 \
-V $SNPsOutput/exome.snps.filtered.vcf \
--excludeNonVariants \
-o $SNPsOutput/exome.snps.filtered.selected.vcf \
-selectType SNP


java -Xmx12g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $GenomeReference \
-nt 5 \
-V $IndelsOutput/exome.indels.filtered.vcf \
--excludeNonVariants \
-o $IndelsOutput/exome.indels.filtered.selected.vcf \
-selectType INDEL
