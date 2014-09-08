#!/bin/bash

#---------------------------Configuration------------------------------
InputFolder=..
OutputFolder=./Mapping2020Combined
mkdir -p $OutputFolder

REFERENCEBWA=/Volumes/tempdata1/tonywang/GATK_ref/hg19BWAindex/hg19bwaidx
REFERENCEFasta=/Volumes/tempdata1/tonywang/GATK_ref/hg19.fasta

CLASSPATH=/Library/Java/Extensions                     # Installation path of PiCard and GATK jar files
tempSpillFolder=/Volumes/tempdata1/tonywang/tempCache1       # used for storing cache files in Java programs

#assumed fastq extension is .fastq.gz, otherwise change below:

FastqExtension="fastq"

#--------------------------end of configuration------------------------




# First step: align the fastq sequence to reference genome

SaiFileListName="SaiFileList2.txt"    # output list of the BWA
#fastqFiles.txt contains paired end reads, separated by a single space

while read line; do

        echo $line
        fastq1=$(echo $line | awk '{print $1}')
        fastqFileName1=$(basename "$fastq1")
        fastqFileName1=${fastqFileName1%%.*}    

        fastq2=$(echo $line | awk '{print $2}')
        fastqFileName2=$(basename "$fastq2")
        fastqFileName2=${fastqFileName2%%.*}    
        echo "fastq1 is $fastq1, and fastq2 is $fastq2"
        echo "fastqFileName1 is $fastqFileName1, and fastqFileName2 is $fastqFileName2" 
        
        bwa aln -t 5 $REFERENCEBWA $fastq1 > $OutputFolder/$fastqFileName1.sai&
        bwa aln -t 5 $REFERENCEBWA $fastq2 > $OutputFolder/$fastqFileName2.sai


done<fastqFiles.txt

if [ -f sampleNameList2.txt ]; then
   rm -rf sampleNameList2.txt
fi

while read line; do

   echo "echo $line"

   SaiFile1base=$(echo $line | awk '{print $1}')
   SaiFile2base=$(echo $line | awk '{print $2}')

   SaiFile1=$(basename "$SaiFile1base")
   fastqFileName1=${SaiFile1%.*}
   
   SaiFile2=$(basename "$SaiFile2base")
   fastqFileName2=${SaiFile2%.*}

   #MB2176_GCCAAT_L004_R2_001
   sampleName=$(echo $fastqFileName1 | cut -f1-3 -d_)
  # sampleName=${fastqFileName1%%_*}       # sample name something like F1616L
   
   RGPU=$(echo $SaiFile1 | cut -f2 -d _)

   echo "$sampleName $RGPU"
   echo "fastqFile is: $fastqFileName1.$FastqExtension"

   echo "$sampleName $RGPU" >> sampleNameList2.txt    #create a sample name list with the correspondong RGPU code
   

   bwa sampe -r '@RG\tID:Exome1\tLB:Exome1\tSM:$sampleName\tPL:HiSeq2000' $REFERENCEBWA $SaiFile1base $SaiFile2base $InputFolder/$fastqFileName1.$FastqExtension $InputFolder/$fastqFileName2.$FastqExtension > $OutputFolder/$sampleName.$RGPU.Aln-PE.sam  # change the PL, LB, ID if necessary


   echo "finished $sampleName" 

done < $SaiFileListName

# Third step: sort the above SAM files

mkdir -p $OutputFolder/sorted  # create directory for storing the sorted Sam files

for file in $OutputFolder/*.Aln-PE.sam; do

      samfilename=$(basename "$file")
      filename=${samfilename%.*}

      java -Xmx8g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/SortSam.jar INPUT=$file \
      OUTPUT=$OutputFolder/sorted/$filename.sorted.sam VALIDATION_STRINGENCY=LENIENT \
      SORT_ORDER=coordinate

done



#Step 4: convert the SAM to BAM

mkdir -p $OutputFolder/BAM

for file in $OutputFolder/sorted/*.sorted.sam; do

      samfilename=$(basename "$file")
      filename=${samfilename%.*}
      java -Xmx10G -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/SamFormatConverter.jar VALIDATION_STRINGENCY=LENIENT INPUT=$file OUTPUT=$OutputFolder/BAM/$filename.bam

#     rm -rf $file

done


for file in $OutputFolder/BAM/*sorted.bam; do

      samfilename=$(basename "$file")
      filename=${samfilename%.*}

      java -Xmx8G -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/MarkDuplicates.jar \
      VALIDATION_STRINGENCY=LENIENT INPUT=$file OUTPUT=$OutputFolder/BAM/$filename.Deduped.bam \
      METRICS_FILE=$OutputFolder/sorted/$filename.metrics REMOVE_DUPLICATES=true ASSUME_SORTED=false

#     rm -rf $file
done

for file in $OutputFolder/BAM/*Deduped.bam; do

      samfilename=$(basename "$file")
      filename=${samfilename%.*}
      java -Xmx15g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/ReorderSam.jar VALIDATION_STRINGENCY=LENIENT INPUT=$file OUTPUT=$OutputFolder/BAM/$filename.Reorder.bam REFERENCE=$REFERENCEFasta
done


# Clean the bam files to set mapQ=0 if unmapped using PiCard

for file in $OutputFolder/BAM/*Reorder.bam; do

      samfilename=$(basename "$file")
      filename=${samfilename%.*}

      java -Xmx10g -Djava.io.tmpdir=$tempSpillFolder -jar $CLASSPATH/CleanSam.jar INPUT=$file OUTPUT=$OutputFolder/BAM/$filename.clean.bam

##      touch $OutputFolder/BAM/$filename.clean.bam
      echo "finished $file"
#     rm -rf $file
     
done

echo "finished cleaning jobs, now starting addgroup.sh"

for file in $OutputFolder/BAM/*.clean.bam; do
    
     samfilename=$(basename "$file")
     sampleName=${samfilename%%.*}

     RGPUCode=$(grep $sampleName ./sampleNameList2.txt | awk '{print $2}')

     if [[ -z "$RGPUCode" ]]; then
           echo "not exists"
           continue;

      else
           echo "not empty"
           java -Xmx10G -jar $CLASSPATH/AddOrReplaceReadGroups.jar INPUT=$file OUTPUT=$OutputFolder/BAM/$samfilename.grp.bam \
           RGID=$sampleName RGLB=NameYourNameHere RGPL=ILLUMINA RGPU=$RGPUCode \
           RGSM=$sampleName RGCN=UCDenver RGDS=YourName

##           touch $OutputFolder/BAM/$samfilename.grp.bam
          
      fi
#    rm -rf $file
done

echo "finished addgroup, now starting index the bam files"


for file in $OutputFolder/BAM/*grp.bam; do

     samtools index $file
     echo "finished index of file $file"
done

echo "all finished! Done with BWA and PiCard, now you can proceed to GATK with the following files:"

ls $OutputFolder/BAM/*grp.bam
