				ASH Viewer
				
  What is it?
  -----------
  ASH Viewer provides graphical view of active session history data within the Oracle instance. 

  Active Session History (ASH) is a view in Oracle that maps a circular buffer in the SGA. 
  The name of the view is V$ACTIVE_SESSION_HISTORY. This view is populated every second 
  and will only contain data for 'active' sessions, which are defined as sessions 
  waiting on a non-idle event or on a CPU.

  ASH Viewer provides graphical Top Activity, similar Top Activity analysis and Drilldown
  of Oracle Enterprise Manager performance page. ASH Viewer store ASH data locally using
  embedded database Oracle Berkeley DB Java Edition. The default capture rate is one snapshot 
  every 30 seconds. ASH Viewer support 10g, 11g version of Oracle DB. Use SYSTEM database user 
  to connect to Oracle DB. Please note that v$active_session_history is a part of the Oracle Diagnostic Pack 
  and requires a purchase of the ODP license.
  
  For Oracle 9i(8i) DB, ASH Viewer emulate ASH, storing active session data on local storage.
  The default capture rate is one snapshot every 1 second. For Oracle 9i(8i) DB,
  user SYSTEM must have access rights to the views sys.x_$ksuse, sys.x_$ksusecst
  
  	create view x_$ksuse as select * from x$ksuse;
	create view x_$ksusecst as select * from x$ksusecst;
	
	grant select on sys.x_$ksuse to system;
	grant select on sys.x_$ksusecst to system;

  System Requirements
  -------------------
  JDK:
    1.5u11 or above.
  Memory:
    Minimum 128 Mb. Recommended 192 Mb.
  Disk:
    Depend on Oracle workload.
  Operating System:
    No minimum requirement.

  Running ASH Viewer
  ----------------
  1) Unpack the archive, eg:
      unzip ashv-<<version>>-bin.zip

  2) A directory called "ashv-<<version>>-bin" will be created.

  3) Download JDBC driver ojdbc14.jar from http://otn.oracle.com and put it to ashv-<<version>>-bin/lib directory.

  4) Make sure JAVA_HOME is set to the location of your JDK, 
  	  see run.cmd/run.sh (on Windows/Unix platform).

  5) Run run.cmd/run.sh (on Window/Unix).

   Known issues
  --------------
   Problem: When running ASH Viewer on JRE6, dragging window slider on Top Activity is too slow
   Workaround: use JDK5+ or JRE5 to run ASH Viewer
   
   Problem: On Oracle 9i, select from v$sql_plan, cause extreme library cache latch contention 
   Workaround: collect statistics on fixed table x$kqlfxpl to resolve this issue:
   				SQL> exec dbms_stats.gather_table_stats('SYS','X$KQLFXPL');
   
   Licensing
  ---------
   Please see the file called license.txt

   ASH Viewer URL
  ----------
   http://ashv.sourceforge.net
   
