#!/bin/bash

#$ -S /bin/bash                 
#$ -cwd
#$ -j y
#$ -o qsub.log
#$ -l mem_free=8G 
#$ -l scratch=10G 
#$ -l h_rt=02:00:00 
#$ -t 1-24                      


#set index from zero for bash arrays
INDEX=$((SGE_TASK_ID-1))


#get samples names from mapping file (due to biohub renaming issue)
SAMPLEIDS=($( cat mapping/mapping.tsv | cut -f 1 | tail -24 ))
FWDS=($( cat mapping/mapping.tsv | cut -f 2 | tail -24 ))
REVS=($( cat mapping/mapping.tsv | cut -f 3 | tail -24 ))
PARENTS=($( cat mapping/mapping.tsv | cut -f 4 | tail -24 ))
PHAGEMIDS=($( cat mapping/mapping.tsv | cut -f 5 | tail -24 ))

SAMPLE="${SAMPLEIDS[$INDEX]}"
PARENT="${PARENTS[$INDEX]}"
PHAGEMID="${PHAGEMIDS[$INDEX]}"
FWD="${FWDS[$INDEX]}"
REV="${REVS[$INDEX]}"


#assign folder paths; clean up old outdirs; make new outdirs
LOGS="logs"
FASTP="1-fastp"
BOWTIE="2-bowtie"
DEPTH="3-depth"

OUTDIRS=($LOGS $FASTP $BOWTIE $DEPTH)
for OUTDIR in "${OUTDIRS[@]}"
do
    mkdir -p $OUTDIR
    find $OUTDIR -name $SAMPLE* -exec rm -rf {} \;
done


#make sample specific logs
exec >> $LOGS/$SAMPLE.log 2>&1


#preamble
echo ""
echo "***********************************************************************************"
date
hostname
echo ""
echo "[ $(date '+%F %H:%M:%S') ] Processing: $SAMPLE"
echo "[ $(date '+%F %H:%M:%S') ] Parent strain: $PARENT"
echo "[ $(date '+%F %H:%M:%S') ] Forward read file: $FWD"
echo "[ $(date '+%F %H:%M:%S') ] Reverse read file: $REV"

#make temp dir in local /scratch, if it exists, otherwise in /tmp
STARTDIR=$(pwd)

if [[ -z "$TMPDIR" ]]; then
  if [[ -d /scratch ]]; then TMPDIR=/scratch/$USER/$SAMPLE; else TMPDIR=/tmp/$USER/$SAMPLE; fi
  mkdir -p "$TMPDIR"
  export TMPDIR
fi

echo ""
echo "[ $(date '+%F %H:%M:%S') ] Copying files to scratch..."
cp reads/$FWD $TMPDIR
cp reads/$REV $TMPDIR
cp ref/$PARENT.fna $TMPDIR
cp ref/$PHAGEMID.fasta $TMPDIR

cd $TMPDIR


#load cluster software
module load CBI
module load bowtie2
module load r


#begin
echo ""
echo "[ $(date '+%F %H:%M:%S') ] Trimming reads..."
/turnbaugh/qb3share/shared_resources/sftwrshare/fastp_v0.20.1/fastp \
    --detect_adapter_for_pe \
    --trim_poly_g \
    --html $SAMPLE-fastp-report.html \
    --thread 16 \
    --in1 $FWD \
    --in2 $REV \
    --out1 $SAMPLE-R1-trimmed.fastq.gz \
    --out2 $SAMPLE-R2-trimmed.fastq.gz 
    

echo ""
echo "[ $(date '+%F %H:%M:%S') ] Combining and indexing references..."
cat $PARENT.fna $PHAGEMID.fasta > combined.fasta

/turnbaugh/qb3share/shared_resources/sftwrshare/bowtie2-2.3.5.1-linux-x86_64/bowtie2-build \
	combined.fasta \
	combined.fasta

echo ""
echo "[ $(date '+%F %H:%M:%S') ] Aligning reads..."
/turnbaugh/qb3share/shared_resources/sftwrshare/bowtie2-2.3.5.1-linux-x86_64/bowtie2 \
    -q \
    -1 $SAMPLE-R1-trimmed.fastq.gz \
    -2 $SAMPLE-R2-trimmed.fastq.gz \
    -x combined.fasta \
    --met-file $SAMPLE-bowtie2.log \
    --threads 16 \
    --sensitive \
    --no-unal \
    -S $SAMPLE.sam
    
echo ""
echo "[ $(date '+%F %H:%M:%S') ] Filtering multi-mapping reads..."
/turnbaugh/qb3share/shared_resources/sftwrshare/samtools-1.9/bin/samtools view \
    -bSq 2 \
    $SAMPLE.sam \
    > $SAMPLE-filtered.bam
    
echo ""
echo "[ $(date '+%F %H:%M:%S') ] Sorting file..."    
/turnbaugh/qb3share/shared_resources/sftwrshare/samtools-1.9/bin/samtools sort \
	$SAMPLE-filtered.bam \
	-o $SAMPLE-sorted.bam

echo ""
echo "[ $(date '+%F %H:%M:%S') ] Calculating depth..."  
/turnbaugh/qb3share/shared_resources/sftwrshare/samtools-1.9/bin/samtools depth \
	$SAMPLE-sorted.bam > $SAMPLE-depth.tsv

echo ""
echo "[ $(date '+%F %H:%M:%S') ] Calculating depth for targeted region..."  
/turnbaugh/qb3share/shared_resources/sftwrshare/samtools-1.9/bin/samtools index \
    $SAMPLE-sorted.bam

/turnbaugh/qb3share/shared_resources/sftwrshare/samtools-1.9/bin/samtools depth \
	-r "${PARENT}"_1:2700000-2900000 \
	$SAMPLE-sorted.bam > $SAMPLE-depth-targeted-region.tsv
        
echo ""
echo "[ $(date '+%F %H:%M:%S') ] Copying files from scratch..."
cp $SAMPLE-fastp-report.html $STARTDIR/$FASTP/$SAMPLE-fastp-report.html
cp $SAMPLE-bowtie2.log $STARTDIR/$BOWTIE/$SAMPLE-bowtie2.log
cp $SAMPLE-depth.tsv $STARTDIR/$DEPTH/$SAMPLE-depth.tsv
cp $SAMPLE-depth-targeted-region.tsv $STARTDIR/$DEPTH/$SAMPLE-depth-targeted-region.tsv


echo ""
echo "[ $(date '+%F %H:%M:%S') ] Cleaning up..."
rm $FWD
rm $REV
rm $PARENT.fna
rm $PHAGEMID.fasta
rm "${SAMPLE}"*.fastq.gz 
rm combined.fasta*
rm $SAMPLE*

echo ""
echo "Done."
echo ""


#postamble
echo "***********************************************************************************"
echo ""
qstat -j $JOB_ID
