set echo off

rem 
rem $Name$		diff-stats-history.sql

rem Diff stats in history to current 
rem
rem	



set termout on verify off serveroutput off long 32000  feed off timing off

prompt Parameter descriptions
prompt
prompt Owner name  : Owner of table whose stats you wish to review (null = current schema)
prompt Table name  : Table for which stats are to be compared
prompt Timestamp   : Timestamp in past (mm/dd/yyyy) to compare to current
prompt % Threshold : Default = 10. Reports differences in stats that exceed this limit.
prompt 



accept t_owner prompt 'Enter the owner name   : '
accept t_table prompt 'Enter the table name   : '

col savtime format a20
col analyzetime format a20

prompt
prompt Stats History
prompt

select  rownum id, a.*
from 
(
select  rowcnt, blkcnt, avgrln, samplesize, 
		to_char(savtime,'mm/dd/yyyy hh24:mi:ss') savtime, 
		to_char(analyzetime,'mm/dd/yyyy hh24:mi:ss') analyzetime
from sys.WRI$_OPTSTAT_TAB_HISTORY
where obj# = (select object_id from dba_objects 
			  where owner = UPPER('&t_owner') and object_name = UPPER('&t_table') and object_type = 'TABLE')
order by savtime desc
) a
;


prompt

accept t_time1 prompt 'Enter the ID for the timestamp to compare: '
accept t_pct NUMBER format '999' default '10' prompt 'Enter the % threshold      : '


col savtime2 new_val time1 noprint

select savtime2
from 
(
select  rownum id, a.*
from 
(
select  rowcnt, blkcnt, avgrln, samplesize, 
		to_char(savtime,'mm/dd/yyyy hh24:mi:ss') savtime, 
		to_char(analyzetime,'mm/dd/yyyy hh24:mi:ss') analyzetime,
		savtime savtime2, analyzetime analyzetime2
from sys.WRI$_OPTSTAT_TAB_HISTORY
where obj# = (select object_id from dba_objects 
			  where owner = UPPER('&t_owner') and object_name = UPPER('&t_table') and object_type = 'TABLE')
order by savtime desc
) a
)
where id = &t_time1
;


-- Example
/*
select * from table(
       dbms_stats.diff_table_stats_in_history('BIGDUDE','PROFIT_CENTER',to_timestamp('01/09/2011','mm/dd/yyyy'),null,1)
);
*/

select * from table(
       dbms_stats.diff_table_stats_in_history('&t_owner','&t_table','&time1',null,1)
);


undefine t_owner   
undefine t_table   
undefine t_time1
undefine t_pct	  

set serveroutput on feed on timing on

