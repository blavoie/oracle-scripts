-- Request Misses = 0 can mean the Reserved Area is too big.   
-- Request Misses always increasing but Request Failures not increasing can mean the Reserved Area is too small.  In this case flushes in the Shared Pool satisfied the memory needs.   
-- Request Misses and Request Failures always increasing can mean the Reserved Area is too small and flushes in the Shared Pool are not helping (likely got an ORA-04031).


@plusenv
set heading off
set feedback off
Select  'Reserved Pool Stats...' from dual;

set heading on
col free_space for 999,999,999,999 head "TOTAL FREE"
col avg_free_size for 999,999,999,999 head "AVERAGE|CHUNK SIZE"
col free_count for 999,999,999,999 head "COUNT"
col request_misses for 999,999,999,999 head "REQUEST|MISSES"
col request_failures for 999,999,999,999 head "REQUEST|FAILURES"
col max_free_size for 999,999,999,999 head "LARGEST CHUNK"

select free_space
      ,avg_free_size
      ,free_count
      ,max_free_size
      ,request_misses
      ,request_failures
from v$shared_pool_reserved;

set heading off
set feedback off
select 'Reserved Pool Request Hit Ratio...' from dual;

set heading on
col requests for 999,999,999 
col last_failure_size for 999,999,999 head "LAST FAILURE| SIZE " 
col last_miss_size for 999,999,999 head "LAST MISS|SIZE " 
col pct for 999 head "HIT|% " 
col request_failures for 999,999,999,999 head "FAILURES" 
select requests
      ,trunc(100-(100*(request_misses/decode(requests,0,1,requests))),0) PCT
      ,request_failures
      ,last_miss_size
      ,last_failure_size 
from v$shared_pool_reserved;
