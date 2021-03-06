######################################################################
# Copyright (c)  2012 by Oracle Corporation
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
##  V2.1.0  
##  11/26/2007     oswlnxtop.sh     Fixed bug with awk script. Bug caused 
##  V2.1.1                          no output on some linux platforms  
##  12/16/2008     OSWg.jar         Fixed problem reading aix
##  V2.1.2                          iostat files   
##  07/31/2009     OSWatcher.sh     Release 3.0 for EXADATA
##  V3.0.0                                                                                         
##  02/11/11       OSWg.jar         Fixed bug with linux iostat entries
##  V3.0.1                          spanning multile lines
##  05/04/11                        Fixed directory permission on
##  V3.0.2                          install of osw.tar
##  02/01/12                        Release 4.0 Black Box
##  V4.0.0
######################################################################
WHAT'S NEW IN THIS RELEASE:
OSWatcher has been renamed to OSW Black Box to avoid confusion
with other Oracle utilities also named OSWatcher.
This release introduces the OSW Black Box Analyzer (oswbba).
This analyzer includes functionality of OSWg with the addition of
an analyzer which makes OSW Black Box self analyzing.
This version tries to obtain cpu count from the OS so the Black Box
Analyzer can look for cpu problems in addition to memory and i/o and
provide an instantaneous analysis of the OSWatcher logs. 
######################################################################
OSW (OSWatcher) is a series of unix shell scripts used to collect OS 
and network metrics. These metrics are then archived to ascii files. 
This tool runs continuously but saves only the last x number of hours 
of data. The output of the tool resides in the archive subdirectory.
######################################################################
INSTALLATION:

Once the tool has been downloaded to the directory you wish to install,
untar the oswbb.tar file. This will create a directory called oswbb. The 
oswbb files are then untared into this new directory. Next, make sure to 
change the file permissions on these files to execute by using chmod.
$ chmod 744 *
######################################################################
LOCATION:

OSWbb writes it's location in a heartbeat file named osw.hb in the /tmp
directory. This is done so other oracle utilities like RAC-DDT and RDA
can find OSWbb data when these utilities are run.
######################################################################
CONFIGURATION:

This tool collects the following kinds of data using the resident host
os utilities. Make sure these utilities are in your PATH and that you
have permission to execute them...

Example:

    NETSTAT=Configured in file osw.net
    IOSTAT='iostat 1 3'
    VMSTAT='vmstat 1 3 '
    TOP='top -d1'
    PSELF='ps -elf'
    MPSTAT='mpstat 1 3' 
    
To change or reconfigure the tool to use different arguments to the 
host utility edit the OSWatcher.sh file (Look for the section 
CONFIGURATION). The tool comes preconfigured for each unix os by 
default. Oracle Support recommends you use the recommended 
configuration and do not modify unless instructed by Oracle Support.
######################################################################
OPTIONAL UNIX ENVIRONMENT VARIABLE:

An optional environment variable to control the amount of samples the
ps command collects is available. This can be done by specifying

setenv OSW_PS_SAMPLE_MULTIPLIER n
where n = number of samples to skip

Example:
setenv OSW_PS_SAMPLE_MULTIPLIER 3 

OSWatcher Black Box is started with a default value of 20 seconds. This would
cause ps data to be collected 1 time every 60 seconds (20 * 3) instead
of every 20 seconds.
######################################################################
MONITORING PRIVATE NETWORKS:

Oracle Support recommends you use this tool to monitor your RAC private
networks. Create a file named private.net or look at the 
Exampleprivate.net file and manually enter in the hostname or ipaddress
you wish to monitor. Each unix os uses slightly different arguments to
the traceroute command. Refer to Exampleprivate.net for examples for 
each unix os.
######################################################################
OSWbba Date Compliance:

To force the unix date mask to comply with OSWbba formatting,  the
parameter oswgCompliance by default is now set to 1.

oswgCompliance=1

Setting this parameter will force a date mask that is readable by OSWbba
for vmstat, iostat and top files. This parameter will not change the date
mask in any other files. Set this parameter to 0 if you do not want the date
change for analysis by OSWbba.
######################################################################
Exadata:

Exadata users must run OSWatcher as the root user. Failure to do so
will result in a warning and the shutdown of OSWatcher.
######################################################################
STARTING OSW:

To start the OSWbb utility execute the startOSWbb.sh shell script. This 
script has 2 arguments which control the frequency that data is 
collected and the number of hours worth of data to archive. An optional
3rd argument allows the user to specify a zip utility name to compress
the files after they have been created:

ARG1 = snapshot interval in seconds.
ARG2 = the number of hours of archive data to store.
ARG3 (optional) = the name of the zip utility to run if the user wants to
                  compress the files automatically after creation.

If you do not enter any arguments the script runs with default values 
of 30 and 48 meaning collect data every 30 seconds and store the last 48 
hours of data in archive files.

Example 1:

./startOSWbb.sh 60 10
This would start the tool and collect data at 60 second intervals and 
log the last 10 hours of data to archive files.

Example 2:

./startOSWbb.sh
This would use the default values of 30, 48 and collect data at 30 
second intervals and log the last 48 hours of data to archive files.

Example 3:

./startOSWbb.sh 20 24 gzip
This would start the tool and collect data at 20 second intervals and 
log the last 24 hours of data to archive files. Each file would be
compressed by running the gzip utility after creation.
######################################################################
STOPPING OSW Black Box:

To stop the OSWbb utility execute the stopOSWbb.sh command. This terminates
all the processes associated with the tool.

Example:

./stopOSWbb.sh


