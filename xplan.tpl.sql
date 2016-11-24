set echo on
set pagesize 120

alter session set statistics_level=all;

var b1 number
exec :b1 := 1225986;

set termout off

-- insert stuff here

set termout on
        
select * from table(dbms_xplan.display_cursor(null, null, 'allstats last advanced'));
