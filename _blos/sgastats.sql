set pagesize 999

break on pool skip 1
compute sum of bytes mbytes gbytes on pool

-- Complete and detailled statistics
select pool, 
       name, 
       bytes,
       round(bytes/(1024*1024),      3) as mbytes,
       round(bytes/(1024*1024*1024), 3) as gbytes
from   v$sgastat
order by pool, 
         name;
         
clear computes
clear breaks         