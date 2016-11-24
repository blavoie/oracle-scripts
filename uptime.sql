col host_name format a45
col instance_name format a20
col startup_time format a25
col uptime format a50 

select 
    host_name 
   ,instance_name
   ,to_char(startup_time,'YYYY MON DD HH24:MI:SS') startup_time
   ,floor(sysdate - startup_time) || ' day(s) ' ||
    trunc(24*((sysdate-startup_time) - 
    trunc(sysdate-startup_time))) || ' hour(s) ' ||
    mod(trunc(1440*((sysdate-startup_time) - 
    trunc(sysdate-startup_time))), 60) ||' minute(s) ' ||
    mod(trunc(86400*((sysdate-startup_time) - 
    trunc(sysdate-startup_time))), 60) ||' seconds' uptime
from v$instance;