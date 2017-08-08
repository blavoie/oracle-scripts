set feedback off
undefine v_dbid
undefine v_inst
undefine v_minsnap
undefine v_maxsnap
undefine v_sqlid

accept v_sqlid prompt 'Please enter sql_id for analysis: '

column begin_interval_time format a30
column end_interval_time format a30

column dbid new_value v_dbid NOPRINT;
column instance_number new_value v_inst NOPRINT;
column min_snap new_value v_minsnap NOPRINT;
column max_snap new_value v_maxsnap NOPRINT;

SELECT d.dbid, instance_number
FROM v$database d, v$instance i;

select max(snap_id) max_snap
from dba_hist_snapshot
where  instance_number = (select instance_number from v$instance)
/

select max(snap_id) min_snap
from dba_hist_snapshot
where  instance_number = (select instance_number from v$instance)
and    snap_id < &&v_maxsnap
/


select output from table(dbms_workload_repository.awr_sql_report_text(&&v_dbid,&&v_inst,&&v_minsnap, &&v_maxsnap, '&&v_sqlid'))
/

set feedback on 
