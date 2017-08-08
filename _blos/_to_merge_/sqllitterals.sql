-- Detecting use of litterals?
select s.plan_hash_value, 
       count(*), 
       collect(s.sql_text) as sqls
from   gv$sql s
where  s.plan_hash_value <> 0  
and    s.parsing_schema_name = 'ICU'
group  by s.plan_hash_value
order by count(*) desc;

/*
select s.inst_id, s.sql_id, s.child_number, s.executions, s.parsing_schema_name, s.sql_text
from   gv$sql s
where  s.plan_hash_value = '2151562988'
order by s.sql_id, s.child_number;
*/


