#!/usr/bin/ksh
######################################################################
# Copyright (c)  2011 by Oracle Corporation
# OSWatcher.sh
# This is the main OSWbb program. This program is started by running 
# startOSWbb.sh
######################################################################
# Modifications Section:
######################################################################
##     Date        File            Changes
######################################################################
##  04/18/2005                      Baseline version 1.2.1 
##				              
##  05/19/2005     OSWatcher.sh     Add -x option to iostat on linux 
##  V1.3.1                          Add code to write pwd to /tmp/osw.hb
##                                  for rac_ddt to find osw archive 
##                                  files
##                                 
##  V1.3.2         OSWatcher.sh     Remove -f flag from $TOP for HP Conf
##                                  section. Append -f flag to $TOP when
##                                  running the HP top cmd   
##
##  09/29/2006     OSWatcher.sh     Added $PLATFORM key and OSW version 
##  V2.0.0                          info to header of all files. This 
##                                  will enable parsing by PTA and 
##                                  OSWg  
##
##  10/03/2006     OSWg.jar         Fixed format problem for device names 
##  V2.0.1                          greater than 30 characters   
##                                  
##  10/06/2006     OSWg.jar         Fixed linux flag to detect linux
##  V2.0.2                          archive files. Fixed bug  with
##                                  empty lists causing exceptions
##                                  when graphing data on platforms
##                                  other than solaris   
##  07/24/2007     OSWatcher.sh     Added enhancements requested by
##  V2.1.0                          linux bde. These include using a
##                                  environment variable to control the
##                                  amount of ps data, changes to top
##                                  and iostat commands, change format
##                                  of filenames to yy.mm.dd, add 
##                                  optional flag to compress files.
##                                  Added -D flag for aix iostat  
##  07/24/2007     oswlnxtop.sh     Created new file for linux top
##  V2.1.0                          collection.
##  07/24/2007     oswlnxio.sh      Created new file for linux iostat
##  V2.1.0                          collection.   
##  07/24/2007     startOSW.sh      Added optional 3rd parameter to 
##  V2.1.0                          compress files           
##  11/26/2007     oswlnxtop.sh     Fixed bug with awk script. Bug caused 
##  V2.1.1                          no output on some linux platforms 
##  12/16/2008     OSWg.jar         Fixed problem reading aix
##  V2.1.2                          iostat files
##  06/16/2009     OSWg.jar         Release 3.0 for EXADATA
##  V3.0.0                          
##  02/11/11       OSWg.jar         Bug Fix for linux iostat spanning
##  V3.0.1                          multiple lines
##  05/04/11                        Fixed directory permission on
##  V3.0.2                          install of osw.tar
##  02/01/12       OSWatcher.sh     Release 4.0 for OSWbb
##  V4.0.0
######################################################################

typeset -i snapshotInterval=$1
typeset -i archiveInterval=$2
typeset -i zipfiles=0
typeset -i status=0
typeset -i vmstatus=0
typeset -i mpstatus=0
typeset -i iostatus=0
typeset -i psstatus=0
typeset -i netstatus=0
typeset -i topstatus=0
typeset -i rdsstatus=0
typeset -i ibstatus=0
typeset -i ZERO=0
typeset -i PS_MULTIPLIER_COUNTER=0
zip=$3
lasthour="0"
PLATFORM=`/bin/uname`
hostn=`hostname`
version="v4.0"

######################################################################
# CPU COUNT
# CPU Count is used by oswbba to look for cpu problems.
# OSWbb will run OS specific commands in the section 
# (Discovery of CPU COUNT) to automatically determine the CPU COUNT.
# In case these commands fail because of system privs, the CPU COUNT
# can be manually set below by changing cpu_count from 0 to the number
# of CPU's on your system.
######################################################################

typeset -i cpu_count=0


######################################################################
# OSWbba time stamp format
# This parameter allows oswbba to analyze files using a standardized
# time stamp format. Setting oswgCompliance=1 sets the time stamp to a 
# standard ENGLISH time format. if you do not want OSWbba to analyze 
# your files or you want to use your own time stamp format you can
# overide and set this value to 0
######################################################################

oswgCompliance=1

######################################################################
# Loading input variables
######################################################################
test $1
if [ $? = 1 ]; then
    echo
    echo "Info...You did not enter a value for snapshotInterval."
    echo "Info...Using default value = 30"
    snapshotInterval=30   
fi 
test $2
if [ $? = 1 ]; then
    echo "Info...You did not enter a value for archiveInterval."
    echo "Info...Using default value = 48"
    archiveInterval=48
fi  
test $3
if [ $? != 1 ]; then
       echo "Info...Zip option IS specified. " 
       echo "Info...OSW will use "$zip" to compress files."
       zipfiles=1
fi      


######################################################################
# Now check to see if snapshotInterval and archiveInterval are valid
######################################################################
test $snapshotInterval
if [ snapshotInterval -lt 1 ]; then
    echo "Warning...Invalid value for snapshotInterval. Overriding with default value = 30"
    snapshotInterval=30     
fi
test $archiveInterval 
if [ archiveInterval -lt 1 ]; then
    echo "Warning...Invalid value for archiveInterval . Overriding with default value = 48"
    archiveInterval=48      
fi  

######################################################################
# Now check to see if unix environment variable
# OSW_PS_SAMPLE_MULTIPLIER has been set
######################################################################
PS_MULTIPLIER=`env | grep OSW_PS_SAMPLE_MULTIPLIER | wc -c`
if [ $PS_MULTIPLIER = $ZERO ];
then
  OSW_PS_SAMPLE_MULTIPLIER=0 
fi

######################################################################
# Add check for EXADATA Node. OSW must be run as root user else
# nodify and do not collect additional EXADATA stats and exit
######################################################################
grep node:STORAGE /opt/oracle.cellos/image.id > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "EXADATA found on your system."
  XFOUND=1
else
  XFOUND=0
fi

if [ $XFOUND = 1 ]; then

  AWK=/usr/bin/awk
  RUID=`/usr/bin/id|$AWK -F\( '{print $2}'|$AWK -F\) '{print $1}'`
  if [ ${RUID} != "root" ];then

    echo "You must be logged in as root to run OSWatcher for EXADATA."
    echo "No EXADATA stats will be collected."
    echo "Log in as root and restart OSWatcher."
    exit

  fi

fi

######################################################################
# Create log subdirectories if they don't exist. Also create oswbba
# subdirectories if they don't exist. 
######################################################################
if [ ! -d archive ]; then
        mkdir archive
fi        
if [ ! -d archive/oswps ]; then
        mkdir -p archive/oswps
fi        
if [ ! -d archive/oswtop ]; then
        mkdir -p archive/oswtop
fi       
if [ ! -d archive/oswnetstat ]; then
        mkdir -p archive/oswnetstat
fi  
if [ ! -d archive/oswiostat ]; then
        mkdir -p archive/oswiostat
fi
if [ ! -d archive/oswvmstat ]; then
        mkdir -p archive/oswvmstat
fi 
if [ ! -d archive/oswmpstat ]; then
        mkdir -p archive/oswmpstat
fi  
if [ ! -d archive/oswprvtnet ]; then
        mkdir -p archive/oswprvtnet
fi  
if [ ! -d locks ]; then
        mkdir locks
fi        
if [ ! -d tmp ]; then
        mkdir tmp 
fi
if [ ! -d profile ]; then
        mkdir profile 
fi
if [ ! -d analysis ]; then
        mkdir analysis 
fi
if [ ! -d gif ]; then
        mkdir gif 
fi
######################################################################
# Create additional EXADATA subdirectories if they don't exist
######################################################################
if [ $XFOUND = 1 ]; then

  if [ ! -d archive/osw_ib_diagnostics ]; then
        mkdir -p archive/osw_ib_diagnostics
  fi

  if [ ! -d archive/osw_rds_diagnostics ]; then
        mkdir -p archive/osw_rds_diagnostics
  fi

fi

######################################################################
# Create additional linux subdirectories if they don't exist
######################################################################
case $PLATFORM in
  Linux)
    mkdir -p archive/oswmeminfo
    mkdir -p archive/oswslabinfo
  ;;
esac   

######################################################################
# Remove lock.file if it exists 
######################################################################
if [ -f locks/vmlock.file ]; then
  rm locks/vmlock.file
fi
if [ -f locks/mplock.file ]; then
  rm locks/mplock.file
fi
if [ -f locks/pslock.file ]; then
  rm locks/pslock.file
fi
if [ -f locks/toplock.file ]; then
  rm locks/toplock.file
fi
if [ -f locks/iolock.file ]; then
  rm locks/iolock.file
fi
if [ -f locks/netlock.file ]; then
  rm locks/netlock.file
fi
if [ -f locks/rdslock.file ]; then
  rm locks/rdslock.file
fi
if [ -f locks/iblock.file ]; then
  rm locks/iblock.file
fi
if [ -f tmp/xtop.tmp ]; then
  rm tmp/xtop.tmp
fi
if [ -f tmp/ltop.tmp ]; then
  rm tmp/ltop.tmp
fi

######################################################################
# CONFIGURATION  Determine Host Platform
# 
# New in release 4.0, TOP parameters are now configured in the file
# xtop.sh. This was changed because 2 snapshots of top are required 
# because the first sample is since system startup and is now 
# discarded with only the second sample being being saved in the 
# oswtop directory. The previous top commands still exist in this
# section and are used only for the discovery of top on your system.
######################################################################
case $PLATFORM in
  Linux)
######################################################################
#   The parameters for linux iostat are now configured in file 
#   oswlnxxio.sh and supercede the following value for iostat
######################################################################
    IOSTAT='iostat -x 1 3'
    VMSTAT='vmstat 1 3'
    TOP='eval top -b -n 1 | head -50'
    PSELF='ps -elf'
    MPSTAT='mpstat 1 3'
    MEMINFO='cat /proc/meminfo'
    SLABINFO='cat /proc/slabinfo'
    ;;
  HP-UX|HI-UX)
    IOSTAT='iostat 1 3'
    VMSTAT='vmstat 1 3'
    TOP='top -d 1'
    PSELF='ps -elf'
    MPSTAT='sar -A -S 1 3'  
    ;;
  SunOS)
    IOSTAT='iostat -xn 1 3'
    VMSTAT='vmstat 1 3 '
    TOP='top -d2 -s1'
    PRSTAT='prstat 1 2'
    PSELF='ps -elf'
    MPSTAT='mpstat 1 3'    
    ;;
  AIX)
    IOSTAT='iostat -D 1 3'
    VMSTAT='vmstat 1 3'
    TOP='top -Count 1'
    PSELF='ps -elf'
    MPSTAT='mpstat 1 3'  
    ;;
  OSF1)
    IOSTAT='iostat 1 3'
    VMSTAT='vmstat 1 3'
    TOP='top -d1'
    PSELF='ps -elf'
    MPSTAT='sar -S'  
    ;;
esac

######################################################################
# Test for discovery of os utilities. Notify if not found.
######################################################################
echo ""
echo "Testing for discovery of OS Utilities..."

$VMSTAT > /dev/null 2>&1
if [ $? = 0 ]; then
  echo "VMSTAT found on your system."
  VMFOUND=1
else
  echo "Warning... VMSTAT not found on your system. No VMSTAT data will be collected."
  VMFOUND=0
fi
VMFOUND=1
$IOSTAT > /dev/null 2>&1
if [ $? = 0 ]; then
  echo "IOSTAT found on your system."
  IOFOUND=1
else
  echo "Warning... IOSTAT not found on your system. No IOSTAT data will be collected."
  IOFOUND=0
fi

$MPSTAT > /dev/null 2>&1
if [ $? = 0 ]; then
  echo "MPSTAT found on your system."
  MPFOUND=1
else
  echo "Warning... MPSTAT not found on your system. No MPSTAT data will be collected."
  MPFOUND=0
fi

netstat > /dev/null 2>&1
if [ $? = 0 ]; then
  echo "NETSTAT found on your system."
  NETFOUND=1
else
  echo "Warning... NETSTAT not found on your system. No NETSTAT data will be collected."
  NETFOUND=0
fi

case $PLATFORM in
  AIX)
    TOPFOUND=1
    ;;
  SunOS)  
    $TOP > /dev/null 2>&1
    if [ $? = 0 ]; then
      echo "TOP found on your system."
      TOPFOUND=1
    else
     $PRSTAT > /dev/null 2>&1
     if [ $? = 0 ]; then
      echo "PRSTAT found on your system."
      TOPFOUND=1
      TOP=$PRSTAT
     else
      echo "Warning... TOP/PRSTAT not found on your system. No TOP data will be collected."
      TOPFOUND=0
     fi
    fi
    ;;
  *)  
    $TOP > /dev/null 2>&1
    if [ $? = 0 ]; then
      echo "TOP found on your system."
      TOPFOUND=1
    else
     echo "Warning... TOP not found on your system. No TOP data will be collected."
     TOPFOUND=0
    fi
    ;;  
esac

case $PLATFORM in
  Linux)
    $MEMINFO > /dev/null 2>&1
    if [ $? = 0 ]; then
      MEMFOUND=1
    else
      echo "Warning... /proc/meminfo not found on your system."
      MEMFOUND=0
    fi
    $SLABINFO > /dev/null 2>&1
    if [ $? = 0 ]; then
      SLABFOUND=1
    else
      echo "Warning... /proc/slabinfo not found on your system."
      SLABFOUND=0
    fi
  ;;
esac 

######################################################################
# Discovery of CPU COUNT. Notify if not found.
######################################################################

echo ""
if [ $cpu_count = 0 ]; then

echo "Testing for discovery of OS CPU COUNT"
echo "OSWbb is looking for the CPU COUNT on your system"
echo "CPU COUNT will be used by oswbba to automatically look for cpu problems"
echo ""
case $PLATFORM in
  Linux)
    cpu_count=`cat /proc/cpuinfo|grep processor|wc -l`
    ;;
  HP-UX|HI-UX)
    cpu_count=`ioscan -C processor | grep processor | wc -l` 
    ;;
  SunOS)
    cpu_count=`psrinfo -v|grep "Status of processor"|wc -l`   
    ;;
  AIX)
    cpu_count=`lsdev -C|grep Process|wc -l`
    ;;
  OSF1)

    ;;
esac


if [ $cpu_count -gt 0 ]; then
  echo "CPU COUNT found on your system."
  echo "CPU COUNT =" $cpu_count
else
  echo " "
  echo "Warning... CPU COUNT not found on your system."
  echo " "
  echo " "
  echo "Defaulting to CPU COUNT = 1"
  echo "To correctly specify CPU COUNT"
  echo "1. Correct the error listed above for your unix platform or"
  echo "2. Manually set cpu_count on OSWatcher.sh line 16 or"
  echo "3. Do nothing and accept default value = 1"
  cpu_count=1
fi

else
  echo "Maunal override of CPU COUNT in effect"
  echo "CPU COUNT =" $cpu_count
fi

echo ""
echo "Discovery completed."
echo ""
sleep 15
echo "Starting OSWatcher Black Box "$version "  on "`date`
echo "With SnapshotInterval = "$snapshotInterval
echo "With ArchiveInterval = "$archiveInterval 
echo ""
echo "OSWatcher Black Box - Written by Carl Davis, Center of Expertise, Oracle Corporation"
echo "For questions on install/usage please go to MOS (Note:301137.1)"
echo "If you need further assistance or have comments or enhancement"
echo "requests you can email me Carl.Davis@Oracle.com"
sleep 5
echo ""
echo "Starting Data Collection..."
echo ""

######################################################################
# Start OSWFM the File Manager Process
######################################################################
./OSWatcherFM.sh $archiveInterval &
######################################################################
# Loop Forever
######################################################################

until test 0 -eq 1
do

echo "oswbb heartbeat:"`date` 
pwd > /tmp/osw.hb

######################################################################
# Generate generic log file string depending on what hour of the day   
# it is. Have 1 report per hour per operation.
######################################################################
#hour=`date +'%m.%d.%y.%H00.dat'`
hour=`date +'%y.%m.%d.%H00.dat'`

######################################################################
# VMSTAT
######################################################################
if [ $VMFOUND = 1 ]; then
  if [ $hour != $lasthour ]; then
    echo $PLATFORM OSW $version $hostn >> archive/oswvmstat/${hostn}_vmstat_$hour
    echo "SNAP_INTERVAL" $snapshotInterval  >> archive/oswvmstat/${hostn}_vmstat_$hour
    echo "CPU_COUNT" $cpu_count  >> archive/oswvmstat/${hostn}_vmstat_$hour
    if [ $zipfiles = 1 ]; then
      if [ -f  archive/oswvmstat/${hostn}_vmstat_$lasthour ]; then
       $zip archive/oswvmstat/${hostn}_vmstat_$lasthour &
       fi
    fi
  fi

  if [ -f locks/vmlock.file ]; then
    vmstatus=1
  else
    touch locks/vmlock.file
    if [ $vmstatus = 1 ]; then
      echo "***Warning. VMSTAT response is spanning snapshot intervals." 
      vmstatus=0
    fi    
    ./vmsub.sh archive/oswvmstat/${hostn}_vmstat_$hour "$VMSTAT" $oswgCompliance & 

  fi  
    
fi

######################################################################
# MPSTAT
######################################################################
if [ $MPFOUND = 1 ]; then
  if [ $hour != $lasthour ]; then
    echo $PLATFORM OSW $version  >> archive/oswmpstat/${hostn}_mpstat_$hour
    if [ $zipfiles = 1 ]; then
      if [ -f  archive/oswmpstat/${hostn}_mpstat_$lasthour ]; then
        $zip archive/oswmpstat/${hostn}_mpstat_$lasthour &
      fi 
    fi    
  fi


  if [ -f locks/mplock.file ]; then
    mpstatus=1
  else
    touch locks/mplock.file
    if [ $mpstatus = 1 ]; then
      echo "***Warning. MPSTAT response is spanning snapshot intervals." 
      mpstatus=0
    fi     
   ./mpsub.sh archive/oswmpstat/${hostn}_mpstat_$hour "$MPSTAT" $oswgCompliance & 

  fi  
  
fi

######################################################################
# NETSTAT
# NETSTAT configured in oswnet.sh file
######################################################################
if [ $NETFOUND = 1 ]; then
  if [ $hour != $lasthour ]; then
    echo $PLATFORM OSW $version >> archive/oswnetstat/${hostn}_netstat_$hour
    if [ $zipfiles = 1 ]; then
      if [ -f  archive/oswnetstat/${hostn}_netstat_$lasthour ]; then
        $zip archive/oswnetstat/${hostn}_netstat_$lasthour &
      fi  
    fi     
  fi
 

  if [ -f locks/netlock.file ]; then
    netstatus=1
  else
    touch locks/netlock.file
    if [ $netstatus = 1 ]; then
      echo "***Warning. NETSTAT response is spanning snapshot intervals." 
      netstatus=0
    fi       
    ./oswnet.sh archive/oswnetstat/${hostn}_netstat_$hour &

  fi  
 
fi

######################################################################
# IOSTAT
######################################################################
if [ $IOFOUND = 1 ]; then
  if [ $hour != $lasthour ]; then
    echo $PLATFORM OSW $version  >> archive/oswiostat/${hostn}_iostat_$hour 
    if [ $zipfiles = 1 ]; then
      if [ -f  archive/oswiostat/${hostn}_iostat_$lasthour ]; then
        $zip archive/oswiostat/${hostn}_iostat_$lasthour &
      fi 
    fi      

  fi


  if [ -f locks/iolock.file ]; then
    iostatus=1
  else
    touch locks/iolock.file
    if [ $iostatus = 1 ]; then
      echo "***Warning. IOSTAT response is spanning snapshot intervals." 
      iostatus=0
    fi     
    case $PLATFORM in
      Linux)
        ./oswlnxio.sh archive/oswiostat/${hostn}_iostat_$hour &
      ;;
      *)
        ./iosub.sh archive/oswiostat/${hostn}_iostat_$hour "$IOSTAT" $oswgCompliance &
      ;;
    esac 
  
  fi  
 
fi

######################################################################
# TOP
######################################################################
if [ $TOPFOUND = 1 ]; then

  if [ $hour != $lasthour ]; then
    echo $PLATFORM  OSW $version >> archive/oswtop/${hostn}_top_$hour
    if [ $zipfiles = 1 ]; then
      if [ -f  archive/oswtop/${hostn}_top_$lasthour ]; then    
        $zip archive/oswtop/${hostn}_top_$lasthour &
      fi 
    fi    
  fi

  if [ -f locks/toplock.file ]; then
    topstatus=1
  else
    touch locks/toplock.file
    if [ $topstatus = 1 ]; then
      echo "***Warning. TOP response is spanning snapshot intervals." 
      topstatus=0
    fi     
    case $PLATFORM in
      Linux)
      ./xtop.sh archive/oswtop/${hostn}_top_$hour &
      ;;
      HP-UX|HI-UX) 
        x=0
      ;; 
      AIX)
        ./topaix.sh archive/oswtop/${hostn}_top_$hour
      ;;
      *)
        ./xtop.sh archive/oswtop/${hostn}_top_$hour "$TOP" &
    ;;
    esac 
  fi    

# no file check for HP. Move code outside test above
 
  case $PLATFORM in
      HP-UX|HI-UX) 
    ./xtop.sh archive/oswtop/${hostn}_top_$hour &
    ;; 
      *)
        x=0
    ;;
  esac 

fi

######################################################################
# PS -ELF
######################################################################
  if [ $hour != $lasthour ]; then
    echo $PLATFORM  OSW $version >> archive/oswps/${hostn}_ps_$hour
    if [ $zipfiles = 1 ]; then
      if [ -f  archive/oswps/${hostn}_ps_$lasthour ]; then
        $zip archive/oswps/${hostn}_ps_$lasthour &
      fi 
    fi    
  fi

  if [ -f locks/pslock.file ]; then
    psstatus=1
  else
    touch locks/pslock.file
    if [ $psstatus = 1 ]; then
      echo "***Warning. PS response is spanning snapshot intervals." 
      psstatus=0
    fi     
    if [ $OSW_PS_SAMPLE_MULTIPLIER -gt $ZERO ]; then
      let PS_MULTIPLIER_COUNTER=PS_MULTIPLIER_COUNTER+1

      if [ $PS_MULTIPLIER_COUNTER -eq $OSW_PS_SAMPLE_MULTIPLIER ]; then
          ./oswsub.sh archive/oswps/${hostn}_ps_$hour "$PSELF" $oswgCompliance &
          PS_MULTIPLIER_COUNTER=0
      fi
    else
      ./pssub.sh archive/oswps/${hostn}_ps_$hour "$PSELF" $oswgCompliance &
    fi
  
  fi  
 
######################################################################
# Additional Linux Only Collection
######################################################################
case $PLATFORM in
  Linux)
  if [ $MEMFOUND = 1 ]; then
    ./oswsub.sh archive/oswmeminfo/${hostn}_meminfo_$hour "$MEMINFO" $oswgCompliance & 
  fi  
  if [ $SLABFOUND = 1 ]; then
    ./oswsub.sh archive/oswslabinfo/${hostn}_slabinfo_$hour "$SLABINFO" $oswgCompliance & 
  fi  

  if [ $hour != $lasthour ]; then
    if [ $zipfiles = 1 ]; then
      if [ -f archive/oswmeminfo/${hostn}_meminfo_$lasthour  ]; then
        $zip archive/oswmeminfo/${hostn}_meminfo_$lasthour &
      fi 
      if [ -f archive/oswslabinfo/${hostn}_slabinfo_$lasthour  ]; then
        $zip archive/oswslabinfo/${hostn}_slabinfo_$lasthour &
      fi 
    fi    
  fi
  ;;
esac 

######################################################################
# EXADATA 
######################################################################
if [ $XFOUND = 1 ]; then
  if [ $hour != $lasthour ]; then
    echo $PLATFORM OSW $version $hostn >> archive/osw_ib_diagnostics/${hostn}_ib_$hour
    if [ $zipfiles = 1 ]; then
      if [ -f  archive/osw_ib_diagnostics/${hostn}_ib_$lasthour ]; then
       $zip archive/osw_ib_diagnostics/${hostn}_ib_$lasthour &
       fi
    fi
  fi

  if [ -f locks/iblock.file ]; then
    ibstatus=1
  else
    touch locks/iblock.file
    if [ $ibstatus = 1 ]; then
      echo "***Warning. IB DIAGNOSTICS response is spanning snapshot intervals." 
      ibstatus=0
    fi    
    
     ./oswib.sh archive/osw_ib_diagnostics/${hostn}_ib_$hour &

  fi  


 
  if [ $hour != $lasthour ]; then
    echo $PLATFORM OSW $version $hostn >> archive/osw_rds_diagnostics/${hostn}_rds_$hour
    if [ $zipfiles = 1 ]; then
      if [ -f  archive/osw_rds_diagnostics/${hostn}_rds_$lasthour ]; then
       $zip archive/osw_rds_diagnostics/${hostn}_rds_$lasthour &
       fi
    fi
  fi

  if [ -f locks/rdslock.file ]; then
    rdsstatus=1
  else
    touch locks/rdslock.file
    if [ $rdsstatus = 1 ]; then
      echo "***Warning. VMSTAT response is spanning snapshot intervals." 
      rdsstatus=0
    fi    
   
    ./oswrds.sh archive/osw_rds_diagnostics/${hostn}_rds_$hour &

  fi  
 
fi

######################################################################
# Run traceroute for private networks in file private.net exists
######################################################################
if [ -x private.net ]; then
  if [ -f locks/lock.file ]; then
    status=1
  else
    touch locks/lock.file
    if [ $status = 1 ]; then
      echo "zzz ***Warning. Traceroute response is spanning snapshot intervals." >> archive/oswprvtnet/${hostn}_prvtnet_$hour & 
      status=0
    fi    
   ./private.net >> archive/oswprvtnet/${hostn}_prvtnet_$hour 2>&1 &
  fi 
  if [ $hour != $lasthour ]; then
    if [ $zipfiles = 1 ]; then
      if [ -f archive/oswprvtnet/${hostn}_prvtnet_$lasthour  ]; then
        $zip archive/oswprvtnet/${hostn}_prvtnet_$lasthour &
      fi 
    fi    
  fi
fi

######################################################################
# Sleep for specified interval and repeat
######################################################################

lasthour=$hour
sleep $snapshotInterval
done


 
