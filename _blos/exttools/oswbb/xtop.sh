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

typeset -i lineCounter=1
typeset -i lineStart=1
typeset -i lineRange=1

PLATFORM=`/bin/uname`
echo "zzz ***"`date` >> $1
case $PLATFORM in
      Linux)
      top -b -n2 -d1 > tmp/xtop.tmp 
      ;;
      HP-UX|HI-UX) 
        top -d 2 -f tmp/xtop.tmp
      ;; 
      AIX)
        ./topaix.sh archive/oswtop/${hostn}_top_$hour
      ;;
      *)
       $2 > tmp/xtop.tmp 
    ;;
    esac
 
lineCounter=`cat tmp/xtop.tmp | wc -l | awk '{$1=$1;print}'`
lineStart=lineCounter/2
lineStart=lineStart+1
lineRange=lineCounter-lineStart 

case $PLATFORM in
      Linux)
       tail -$lineRange tmp/xtop.tmp >> tmp/ltop.tmp
       head -50 tmp/ltop.tmp >> $1
       rm tmp/ltop.tmp
      ;;
      *)
       tail -$lineRange tmp/xtop.tmp >> $1
      ;;

esac
rm tmp/xtop.tmp
rm locks/toplock.file


