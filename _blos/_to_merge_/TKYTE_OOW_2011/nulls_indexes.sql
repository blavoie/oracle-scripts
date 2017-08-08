set echo on
set linesize 1000
drop table t;


create table t
as
select a.*, 
       case when mod(rownum,100) > 1 
            then object_type
        end otype
  from all_objects a;

select count(*) from t where otype is null;
begin
    dbms_stats.gather_table_stats( user, 'T' );
end;
/
create index t_idx on t(otype,owner);

set autotrace traceonly explain
select * from t where otype is null;
set autotrace off

drop index t_idx;
create index t_idx on t(otype,0);
set autotrace traceonly explain
select * from t where otype is null;
set autotrace off
