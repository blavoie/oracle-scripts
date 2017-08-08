col message format a75

select round(sofar/totalwork*100,2) as pct,
       elapsed_seconds,
       time_remaining,
       message
from   v$session_longops
where  sofar<>totalwork
order by target, sid;