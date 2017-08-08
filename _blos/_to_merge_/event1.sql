select event, TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED, AVERAGE_WAIT, MAX_WAIT, TIME_WAITED_MICRO
from v$session_event
where sid = &sid
and TOTAL_WAITS > 0
/
