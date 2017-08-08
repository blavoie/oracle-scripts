

col type for a10

select  inst_id, 
		(select username from dba_users where user_id = a.user_id) usernm,
		sql_id,
		plan_hash,
		type,
		cpu,
		wait,
		io,
		total
from (
select
     ash.inst_id, ash.user_id, ash.SQL_ID , ash.SQL_PLAN_HASH_VALUE Plan_hash, aud.name type,
     sum(decode(ash.session_state,'ON CPU',1,0))     cpu,
     sum(decode(ash.session_state,'WAITING',1,0))    -
     sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))    wait ,
     sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))    io ,
     sum(decode(ash.session_state,'ON CPU',1,1))     total
from gv$active_session_history ash,
     audit_actions aud
where SQL_ID is not NULL
   and ash.sql_opcode=aud.action
   and ash.sample_time > sysdate - &minutes /( 60*24)
group by inst_id, user_id, sql_id, SQL_PLAN_HASH_VALUE   , aud.name 
order by sum(decode(session_state,'ON CPU',1,1))   desc
) a where  rownum <= 20
/
