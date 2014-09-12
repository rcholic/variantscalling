while read line; do 
	echo $line 
	trim_galore --fastqc -o CUHN076_repeated_Samples_20140212/fastq_trim4 $line --paired
done < 076OldReadsToTrim.txt
