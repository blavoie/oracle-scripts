/*
 *
 */
set verify off
set pagesize 999

col username      format a13
col prog          format a22
col sql_text      format a41
col sid           format 999
col child_number  format 99999         heading CHILD
col avg_etime     format 9,999,999.99
col etime         format 9,999,999.99
 
select /*!!!EXCLUDE ME!!!*/
       s.sql_id,
       s.child_number,
       s.plan_hash_value                                                            as plan_hash,
       s.executions                                                                 as execs,
       s.elapsed_time / 1000000                                                     as etime,
       (s.elapsed_time / 1000000) / decode (nvl(s.executions, 0), 0, 1, executions) as avg_etime,
       u.username,
       s.sql_text
from   v$sql     s, 
       dba_users u
where  u.user_id = s.parsing_user_id 
and    u.username like upper(nvl('&username',u.username))
and    upper(sql_text) like upper (nvl ('&sql_text', sql_text))
and    sql_id like nvl('&sql_id', sql_id)
and    sql_text not like '%!!!EXCLUDE ME!!!%'     
/