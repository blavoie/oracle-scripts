set lines 155
set pagesize 999
col sql_text for a50
col etime for 999,999.99
col avg_etime for 999,999.99
col avg_lios for 999,999,999
col avg_pios for 999,999,999
clear break
--break on sql_id skip 1 on plan_hash_value skip 1




prompt Top 10 by Elapsed Time:
SELECT * FROM (
select * from (
SELECT sql_id, plan_hash_value, elapsed_time/1000000 etime, executions execs,
(elapsed_time/1000000)/decode(executions,0,1,executions) avg_etime,
buffer_gets/decode(executions,null,1,0,1,executions) avg_lios,
disk_reads/decode(executions,null,1,0,1,executions) avg_pios, substr(sql_text,1,100) sql_text
   FROM V$SQLSTATS
  WHERE elapsed_time > 100)
 ORDER BY avg_etime DESC)
WHERE rownum <= 10
/

