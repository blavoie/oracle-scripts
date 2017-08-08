set echo on
set linesize 1000

begin
    dbms_stats.seed_col_usage( null, null, 10 );
end;
/

select * 
  from t 
 where owner = 'SYS' 
   and object_type = 'DIMENSION';

exec dbms_lock.sleep( 12 );

select dbms_stats.report_col_usage( user, 'T' ) 
  from dual;
