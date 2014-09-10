while read line; do 
	echo $line 
	trim_galore --paired --gz --fastqc -o CUHN076_repeated_Samples_20140212/fastq_trim4 $line;
done < 076OldReadsToTrim.txt
