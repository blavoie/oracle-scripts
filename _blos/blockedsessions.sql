/*
 * Interesting views:
 *    v$locked_object
 *    v$lock 
 *    dba_locks
 *    dba_blockers
 *    dba_waiters
 *    dba_dml_locks
 *
 * Interesting post: http://www.orafaq.com/node/854
 *
 */
 
 -- this one not work???
select   (select username
          from gv$session
          where sid=l1.sid)  as blocker,
         l1.sid               as blocker_sid, 
         ' is blocking ', 
         (select username
          from gv$session
          where sid=l2.sid)   as blockee, 
          l2.sid              as blockee_sid
from  gv$lock l1, 
      gv$lock l2
where l1.block = 1
and   l2.request > 0
and   l1.id1 = l2.id1
and   l1.id2 = l2.id2
/

-- RAC enabled version:

column sess format A20
select substr(decode(request,0,'holder: ','waiter: ')||sid,1,12) sess,
       id1, 
       id2, 
       lmode, 
       request, 
       type, 
       inst_id
from   gv$lock
where  (id1, id2, type) in (select id1, id2, type from gv$lock where request>0)
order by id1, request
/

------------------------------------------------------
-- tx row lock contention
-- see http://www.dba-oracle.com/t_enq_tx_row_lock_contention.htm

select sid, sql_text
from v$session s, v$sql q
where sid in (select sid
from v$session where state in ('WAITING')
and wait_class != 'Idle' and event='enq: TX - row lock contention'
and (
q.sql_id = s.sql_id or
q.sql_id = s.prev_sql_id));

--The blocking session is,
SQL> select blocking_session, sid, serial#, wait_class, seconds_in_wait from v$session
where blocking_session is not NULL order by blocking_session;


-- Processes Waiting on Locks
SELECT
   holding_session bsession_id,
   b.username busername,
   b.machine bmachine,
   waiting_session wsession_id,
   a.username wusername,
   a.machine wmachine,
   c.lock_type type,
   mode_held,
   mode_requested,
   lock_id1,
   lock_id2,
   b.machine
FROM
   sys.v_$session b,
   sys.dba_waiters c,
   sys.v_$session a
WHERE
   c.holding_session=b.sid
   and
   c.waiting_session=a.sid;
   
-- Blockers
SELECT
   a.session_id,
   b.username,
   b.machine,
   type,
   mode_held,
   mode_requested,
   lock_id1,
   lock_id2
FROM
   sys.v_$session b,
   sys.dba_blockers c,
   sys.dba_lock a
WHERE
   c.holding_session=a.session_id
   AND
   c.holding_session=b.sid; 

-- Report on All DML Locks Held
SELECT
   NVL(owner,'SYS') owner,
   session_id,
   name,
   mode_held,
   mode_requested
FROM
   sys.dba_dml_locks
ORDER BY 2;   
   
--- From: http://antognini.ch/2012/03/analysing-row-lock-contention-with-logminer/
SELECT sid, blocking_session, event, sql_text
FROM   v$session LEFT OUTER JOIN v$sqlarea USING (sql_id)
WHERE nvl(blocking_session,sid) IN (SELECT holding_session FROM dba_blockers);   
   
