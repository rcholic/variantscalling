#!/bin/bash
CLASSPATH=/Library/Java/Extensions

dir=../VCF_files
InputVCF=$dir/raw.snps.indels.vcf
SNPsOutput=$dir/SNPs
IndelsOutput=$dir/Indels



java -Xmx12g -Djava.awt.headless=true -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T ApplyRecalibration \
-R /Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta \
-nt 5 \
--input $InputVCF \
-mode SNP \
--ts_filter_level 99.0 \
-recalFile $SNPsOutput/exome.snps.vcf.recal \
-tranchesFile $SNPsOutput/exome.snps.tranches \
-o $SNPsOutput/exome.snps.filtered.vcf


java -Xmx12g -Djava.awt.headless=true -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T ApplyRecalibration \
-R /Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta \
-nt 5 \
--input $InputVCF \
-mode INDEL \
--ts_filter_level 99.0 \
-recalFile $IndelsOutput/exome.indels.vcf.recal \
-tranchesFile $IndelsOutput/exome.indels.tranches \
-o $IndelsOutput/exome.indels.filtered.vcf

