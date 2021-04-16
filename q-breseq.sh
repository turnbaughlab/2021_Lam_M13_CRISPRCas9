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
BRESEQ="2-breseq"
HTML="3-html"

OUTDIRS=($LOGS $FASTP $BRESEQ $HTML)
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
cp ref/$PARENT.gbk $TMPDIR
cp ref/$PHAGEMID.gb $TMPDIR

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
echo "[ $(date '+%F %H:%M:%S') ] Finding mutations..."
/turnbaugh/qb3share/shared_resources/sftwrshare/breseq-0.35.4/bin/breseq \
    -n $SAMPLE \
    -j 8 \
    -o $SAMPLE \
    -r $PARENT.gbk \
    -r $PHAGEMID.gb \
    $SAMPLE-R1-trimmed.fastq.gz $SAMPLE-R2-trimmed.fastq.gz

echo ""
echo "[ $(date '+%F %H:%M:%S') ] Copying files from scratch..."
cp $SAMPLE-fastp-report.html $STARTDIR/$FASTP/$SAMPLE-fastp-report.html
cp -r $SAMPLE/output $STARTDIR/$BRESEQ/$SAMPLE
cp $SAMPLE/output/index.html $STARTDIR/$HTML/$SAMPLE.html 


echo ""
echo "[ $(date '+%F %H:%M:%S') ] Cleaning up..."
rm $FWD
rm $REV
rm $PARENT.gbk
rm $PHAGEMID.gb
rm "${SAMPLE}"*.fastq.gz 
rm -r $SAMPLE

echo ""
echo "Done."
echo ""


#postamble
echo "***********************************************************************************"
echo ""
qstat -j $JOB_ID
