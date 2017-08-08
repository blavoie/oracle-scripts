set linesize 1000
set echo on

drop table t;

create table t
pctfree 20
as
select a.*, 
       case when mod(rownum,100) <= 50 
            then last_ddl_time 
        end end_date
  from all_objects a;

create index t_idx on t(end_date);

select count(*) 
  from t 
 where end_date 
       between to_date( '01-sep-2010', 'dd-mon-yyyy' ) 
           and to_date( '30-sep-2010', 'dd-mon-yyyy' );
pause


begin
   dbms_stats.gather_table_stats(user, 'T');
end;
/
pause

select count(*) cnt, 
       count(distinct end_date) cntd, 
       count(end_date) cnt2, 
       min(end_date) min, 
       max(end_date) max
  from t;
pause


set autotrace traceonly explain
select * 
  from t 
 where end_date 
       between to_date( '01-sep-2010', 'dd-mon-yyyy' ) 
           and to_date( '30-sep-2010', 'dd-mon-yyyy' );
set autotrace off
pause



update t 
   set end_date = to_date( '01-jan-9999','dd-mon-yyyy' ) 
 where end_date is null;
commit;
pause

exec dbms_stats.gather_table_stats(user, 'T');
pause

set autotrace traceonly explain
select * 
  from t 
 where end_date 
       between to_date( '01-sep-2010', 'dd-mon-yyyy' ) 
           and to_date( '30-sep-2010', 'dd-mon-yyyy' );
set autotrace off
pause
