set echo on
set linesize 1000

drop table t;

create table t
as
select a.*, 
       case when rownum < 500
            then 1
            else 99
        end some_status
  from all_objects a
/

begin
	dbms_stats.gather_table_stats(user,'T');
end;
/

select histogram 
  from user_tab_cols 
 where table_name = 'T' 
   and column_name = 'SOME_STATUS';

create index t_idx on t(some_status);

set autotrace traceonly explain
select * from t where some_status = 1;
select * from t where some_status = 99;
set autotrace off

begin
    dbms_stats.gather_table_stats( user, 'T' );
end;
/

select histogram 
  from user_tab_cols 
 where table_name = 'T' 
   and column_name = 'SOME_STATUS';

set autotrace traceonly explain
select * from t where some_status = 1;
select * from t where some_status = 99;
set autotrace off


select * 
  from 
(
select *
  from sys.col_usage$
 where obj# = (select object_id
                 from dba_objects
                where object_name = 'T'
                  and owner = 'OPS$TKYTE' )
)
 unpivot (value for x in 
   ( EQUALITY_PREDS, EQUIJOIN_PREDS, NONEQUIJOIN_PREDS, 
     RANGE_PREDS, LIKE_PREDS, NULL_PREDS ) )
/

select * from t where some_status > 100;


begin
    dbms_stats.gather_table_stats( user, 'T' );
end;
/

select * 
  from 
(
select *
  from sys.col_usage$
 where obj# = (select object_id
                 from dba_objects
                where object_name = 'T'
                  and owner = 'OPS$TKYTE' )
)
 unpivot (value for x in 
   ( EQUALITY_PREDS, EQUIJOIN_PREDS, NONEQUIJOIN_PREDS, 
     RANGE_PREDS, LIKE_PREDS, NULL_PREDS ) )
/

