#!/bin/bash

#-select "DP >= 600"

CLASSPATH=/Library/Java/Extensions

GenomeReference=/Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta
GenomeInterval=/Volumes/tempdata1/tonywang/GATK_ref/Agilent_S03723314_Covered.bed  # Narrow the GATK search restricted to this interval for faster speed
tempSpillFolder=/Volumes/tempdata1/tonywang/GATK_tmp      # temporary cache folder for GATK

dir=../VCF_files
InputVCF=$dir/raw.snps.indels.vcf
SNPsOutput=$dir/SNPs
IndelsOutput=$dir/Indels

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
