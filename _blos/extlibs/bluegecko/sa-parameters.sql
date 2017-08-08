@plusenv
column severity format a10 
column parameter format a60

select     instance_name, 'Warning: ' severity, metrics_name  || DECODE(object_name,'','',': ')  || object_name 
        || '  ' || warning_operator || '  ' || warning_value  parameter, observation_period, consecutive_occurrences
from dba_thresholds
where status = 'VALID'
union
select   instance_name, 'Critical: ' severity, metrics_name  || DECODE(object_name,'','',': ')  || object_name 
       || '  ' || critical_operator || '  ' || critical_value parameter, observation_period, consecutive_occurrences
from dba_thresholds
where status = 'VALID'
order by 2,1
/
