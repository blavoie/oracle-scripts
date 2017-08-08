@plusenv

column Parameter format a30
column sv format a10 heading "Session|Value"
column iv format a10 heading "Instance|Value"

select  a.ksppinm "Parameter" 
       ,b.ksppstvl sv
       ,c.ksppstvl iv
from x$ksppi a, x$ksppcv b, x$ksppsv c 
where a.indx = b.indx 
and a.indx = c.indx 
and a.ksppinm = '_shared_pool_reserved_pct';
