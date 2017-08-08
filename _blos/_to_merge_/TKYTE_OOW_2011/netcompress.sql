spool x

set echo on
set linesize 1000

drop table t;

create table t 
as 
select * 
  from all_objects;

begin
    dbms_stats.gather_table_stats( user, 'T' );
end;
/
pause

set termout off
set arraysize 15
set autotrace traceonly statistics
select * from t;
select * from t order by timestamp;
select * from t order by timestamp, object_type, owner;
set autotrace off
set termout on


set arraysize 1000
set autotrace traceonly statistics
select * from t;
pause
select * from t order by timestamp;
pause
select * from t order by timestamp, object_type, owner;
pause
set autotrace off
set arraysize 100
set autotrace traceonly statistics
select * from t;
pause
select * from t order by timestamp;
pause
select * from t order by timestamp, object_type, owner;
pause
set autotrace off

spool off
!egrep '(bytes sent|consistent gets)' x.lst
