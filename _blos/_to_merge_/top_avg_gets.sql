set lines 155
set pagesize 999
col sql_text for a50
col gets for 999,999,999,999
col avg_etime for 999,999.99
col avg_lios for 999,999,999
col avg_pios for 999,999,999
clear break
break on sql_id skip 1




prompt Top 10 by Gets:
SELECT * FROM (
select * from (
SELECT sql_id, substr(sql_text,1,100) sql_text, executions execs,
(buffer_gets)/decode(executions,0,1,executions) avg_lios,
disk_reads/decode(executions,null,1,0,1,executions) avg_pios,
(elapsed_time/1000000)/decode(executions,0,1,executions) avg_etime
   FROM V$SQLSTATS)
 ORDER BY avg_lios DESC)
WHERE rownum <= 10
/

