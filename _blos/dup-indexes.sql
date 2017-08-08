-- Quick & dirty way to find redundant indexes
-- http://pastebin.com/KBbDwGK8

--set lines 500

col table_owner format a15 trunc
col ind1 format a50 word_wrapped
col ind2 format a50 word_wrapped
col MB format 999,999,999

break on report skip 1
compute sum of mb on report

with t
     as (select table_owner
               ,table_name
               ,index_name
               ,index_owner
               ,listagg (column_name, ',') within group (order by column_position) || ',' cols
         from   dba_ind_columns
         group by table_owner
                 ,table_name
                 ,index_name
                 ,index_owner)
select t2.table_owner
      ,t2.table_name
      ,t2.index_name
      , (select sum (bytes) / 1024 / 1024
         from   dba_segments s
         where      s.segment_name = t2.index_name
                and s.owner = t2.index_owner)
           mb
      ,rtrim (t2.cols, ',') ind1
      ,rtrim (t1.cols, ',') ind2
from   t t1
      ,t t2
where      t1.table_owner = t2.table_owner
       and t1.table_name = t2.table_name
       and t1.index_name <> t2.index_name
       and t1.cols like t2.cols || '%';