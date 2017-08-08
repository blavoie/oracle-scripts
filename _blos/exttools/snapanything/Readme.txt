Readme for the SNAP_ANYTHING scripts.
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~

INSTALLATION
 1.) Review and edit the 1_SNAP_ANYTHING_CREATE_AS_SYS.sql file to your 
     needs. Comments and hints are in the file.
 2.) Execute the script as user sys against your target DB.
 
DEINSTALLATION
 1.) Run the script 0_SNAP_ANYTHING_DROP.sql against the target database.
 2.) The "DROP USER SNAP_ANYTHING;" might fail, because there might be 
     objects in the schema that were not created with the 
	 1_SNAP_ANYTHING_CREATE_AS_SYS.sql script. Review the list of remaing 
	 objects in the SNAP_ANYTHING schema, drop them and then drop the user 
	 SNAP_ANYTHING manually.


WHAT IS THE POINT?
Once installed, the two tables, the PL/SQL package and the scheduler job 
make it very easy to record regular snapshots of the results of SQL queries. 

Since this is something I frequently need to do, e.g. for performance data not 
snapped by STATSPACK/AWR, tracking a list of invalid objects in developer
schemas over longer periods of time, recording AUDIT information from remote 
test/dev databases that are cloned from production every night, etc., I put 
this into it's own schema/setup script for easy installation on different 
databases.
 

USAGE

All you have to do to do a snapshot of query result data in fixed intervals 
is adding a row to the table SNAP_ANYTHING.HIST_QUERIES, like in this example:

INSERT INTO SNAP_ANYTHING.HIST_QUERIES
  (
     NAME,
     QUERY_TEXT,
     TARGET_TABLE,
	 RETENTION_MINUTES, 
     REPEAT_INTERVAL,
     ENABLED
  )
  VALUES
  (
     'Snapshots of V$SESSION',
     'SELECT * FROM V$SESSION',
     'HIST$SESSIONS',
	 24*60, 
     'SYSDATE+(5/24/60)',
     'Y'
  ); 
COMMIT;

This will execute the query 'SELECT * FROM V$SESSION' every five minutes and 
write the result data rows into the table 'HIST$SESSIONS' (in the SNAP_ANYTHING 
schema). If the table doesn't exist, it will be created automatically. The target
table will have all columns returned by the query, plus the columns SNAP_TIME 
(date/time when this data was recorded) and ORDER_ID (row_num of row for this 
snapshot).

The data is automatically cleaned up based on the number in the RETENTION_MINUTES 
column. Putting 1440 there will keep the snapshot data from the last 24 hours 
(purging happens after every snapshot taken).

Columns in HIST_QUERIES:

NAME              Just a descriptive name so you know what it does.
QUERY_TEXT        The SELECT query that should be executed.
TARGET_TABLE      The target table where the recorded data should go.
                  Doesn't have to exist yet.
REPEAT_INTERVAL   Repeat interval for the execution of the query, e.g.
                  'SYSDATE+(5/24/60)' (every 5 minutes) or 'trunc(sysdate)+7+9/24'
				  (once a week at 9:00am)
RETENTION_MINUTES Number of minutes that you want to keep snapshot data for
ENABLED           Y or N. N disables the snapshot collection.

The scheduler job SNAP_ANYTHING.SNAP_ANYTHING_SNAPPER_JOB check the table HIST_QUERIES
for queries that need to be run, based on their REPEAT_INTERVAL setting.

The table HIST_QUERIES_LOG shows the log entries for the snapshots executed by the scheduler 
jobs. The entries in HIST_QUERIES_LOG are limited to the 10 days of snapshot executions.


