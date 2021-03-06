#!/usr/bin/ksh
######################################################################
# Copyright (c)  2007 by Oracle Corporation
# oswlnxtop.sh
# This script is called by OSWatcher.sh. This script is the generic
# data collector shell for collecting linux top data. $1 is the output
# filename for the data collector. This script takes 2 samples of top
# but disregards the first sample, sending only the last sample to the 
# file
######################################################################
echo "zzz ***"`date` >> $1
typeset -i lineCounter=1
typeset -i lineStart=1
typeset -i lineRange=1
top -d 2 -f tmp/htop.tmp
lineCounter=`cat tmp/htop.tmp | wc -l | awk '{$1=$1;print}'`
lineStart=lineCounter/2
lineStart=lineStart+1
lineRange=lineCounter-lineStart 
tail -$lineRange tmp/htop.tmp >> $1
rm tmp/htop.tmp
rm locks/toplock.file


