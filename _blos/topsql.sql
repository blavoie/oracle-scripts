/*
 * TODO: dynamize the metric to order by:
 *    - cpu time
 *    - cpu time / execs
 *    - buffer gets
 *    - buffer gets / execs
 *
 * TODO: permit filter by :
 *    - owner
 *    - sqltext
 *    - minimum execs
 */
set verify off
set pagesize 999

col ela_sec  format 9999999 heading ELA(S)
col cpu_sec  format 9999999 heading CPU(S)
col sql_text format a41

select * 
from   (
         select  ss.sql_id
               , ss.executions                   as execs
               , ss.rows_processed 
               , ss.buffer_gets
               , round(ss.elapsed_time/1000000)  as ela_sec
               , round(ss.cpu_time/1000000)      as cpu_sec
               , ss.disk_reads
               , ss.sorts
			      --, ss.last_active_time
               , ss.sql_text
         from    v$sqlstats ss
         where   ss.executions > 0 
         --order by ss.cpu_time desc
         order by ss.elapsed_time / ss.executions desc
       )
where rownum <= nvl('&number_of_statements', 10);