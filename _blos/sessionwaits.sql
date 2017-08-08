/*
 * TOOD: exclude current statement/session
 * TOOD: select most convenient columns
 */
select s.username, 
       s.osuser, 
       s.machine, 
       s.serial#, 
       w.* 
from   v$session_wait w, 
       v$session      s
where s.sid=w.sid 
and w.wait_class <> 'Idle'
and w.event not in ('SQL*Net message from client', 'rdbms ipc message')
order by s.username 
/

/*
-- RAC Version???
select  s.inst_id, 
        s.username, 
        s.osuser, 
        s.machine, 
        s.serial#, 
        w.* 
from    gv$session_wait w, 
        gv$session      s
where   s.sid=w.sid 
and     w.event not in ( 'SQL*Net message from client', 'rdbms ipc message', 'jobq slave wait')
and     w.wait_class <> 'Idle'
order by s.username
/
*/
