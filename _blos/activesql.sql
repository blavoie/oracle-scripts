/*
   Source: http://www.expertoracleexadata.com/scripts/
   
   This script shows all active SQL statements on the current instance as shown by V$SESSION. Note that you may need to 
   execute it several times to get an idea of whats happening on a system as fast statements may not be “caught” by the 
   this quick and dirty approach.
*/   
set pagesize      999
set linesize      256

col username      format a13
col prog          format a10 trunc
col sql_text      format a41 trunc
col sid           format 9999
col child         format 99999
col avg_etime     format 999,999.99

select   /* IGNORE_ME */
         sid,
         username,
         substr (program, 1, 19) as prog,
         address,
         hash_value,
         b.sql_id,
         child_number child,
         plan_hash_value,
         executions execs,
         (elapsed_time / decode (nvl (executions, 0), 0, 1, executions)) / 1000000 as avg_etime,
         sql_text
from     v$session a,
         v$sql     b
where    status = 'ACTIVE'
and      username is not null
and      a.sql_id = b.sql_id
and      a.sql_child_number = b.child_number
and      sql_text not like '%IGNORE_ME%' -- don't show this query
order by sql_id, sql_child_number;

-- Clear column formats
col username      clear
col prog          clear
col sql_text      clear
col sid           clear
col child         clear
col avg_etime     clear
