#!/bin/bash
CLASSPATH=/Library/Java/Extensions

dir=../VCF_files
InputVCF=$dir/raw.snps.indels.vcf
SNPsOutput=$dir/SNPs
IndelsOutput=$dir/Indels
mkdir -p $SNPsOutput
mkdir -p $IndelsOutput






java -Xmx8g -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T VariantRecalibrator \
-R /Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta \
--input $InputVCF \
-nt 6 \
-resource:mills,known=true,training=true,truth=true,prior=12.0 /Volumes/tempdata1/tonywang/GATK_ref/Mills_and_1000G_gold_standard.indels.hg19.vcf \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 /Volumes/tempdata1/tonywang/GATK_ref/dbsnp_137.hg19.vcf \
-an DP -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ \
--maxGaussians 8 \
-mode INDEL \
-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
-log $IndelsOutput/Indels.log \
-recalFile $IndelsOutput/exome.indels.vcf.recal \
-tranchesFile $IndelsOutput/exome.indels.tranches \
-rscriptFile $IndelsOutput/exome.indels.recal.plots.R





java -Xmx8g -jar $CLASSPATH/GenomeAnalysisTK.jar \
-T VariantRecalibrator \
-R /Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta \
--input $InputVCF \
-nt 8 \
-resource:hapmap,known=false,training=true,truth=true,prior=15.0 /Volumes/tempdata1/tonywang/GATK_ref/hapmap_3.3.hg19.vcf \
-resource:omni,known=false,training=true,truth=true,prior=12.0 /Volumes/tempdata1/tonywang/GATK_ref/1000G_omni2.5.hg19.vcf \
-resource:1000G,known=false,training=true,truth=false,prior=10.0 /Volumes/tempdata1/tonywang/GATK_ref/1000G_phase1.snps.high_confidence.hg19.vcf \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 /Volumes/tempdata1/tonywang/GATK_ref/dbsnp_137.hg19.vcf \
-an DP -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ \
--maxGaussians 8 \
-mode SNP \
-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
-log $SNPsOutput/Snps.log \
-recalFile $SNPsOutput/exome.snps.vcf.recal \
-tranchesFile $SNPsOutput/exome.snps.tranches \
-rscriptFile $SNPsOutput/exome.snps.recal.plots.R
