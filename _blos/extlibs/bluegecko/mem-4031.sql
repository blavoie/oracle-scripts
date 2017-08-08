column kghluops heading "Pins and|Releases" 
column kghlunfu heading "ORA-4031|Errors" 
column kghlunfs heading "Last Error|Size" 
column kghlushrpool heading "Subpool"   

select 
 kghlushrpool 
,kghlurcr 
,kghlutrn 
,kghlufsh 
,kghluops 
,kghlunfu 
,kghlunfs 
from x$kghlu 
where inst_id = userenv('Instance')
/


