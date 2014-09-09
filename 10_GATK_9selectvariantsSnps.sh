#!/bin/bash

#-select "DP >= 600"

CLASSPATH=/Library/Java/Extensions

dir=../VCF_files
InputVCF=$dir/raw.snps.indels.vcf
SNPsOutput=$dir/SNPs
IndelsOutput=$dir/Indels

java -Xmx12g -Djava.io.tmpdir=/Volumes/tempdata1/tonywang/GATK_temp3 -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T SelectVariants \
-R /Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta \
-nt 5 \
-V $SNPsOutput/exome.snps.filtered.vcf \
--excludeNonVariants \
-o $SNPsOutput/exome.snps.filtered.selected.vcf \
-selectType SNP


java -Xmx12g -Djava.io.tmpdir=/Volumes/tempdata1/tonywang/GATK_temp3 -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T SelectVariants \
-R /Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta \
-nt 5 \
-V $IndelsOutput/exome.indels.filtered.vcf \
--excludeNonVariants \
-o $IndelsOutput/exome.indels.filtered.selected.vcf \
-selectType INDEL
