col name format a35

select name,
       bytes,
       to_char(round(bytes/(1024*1024),      2),             '99990.99') as mbytes,
       to_char(round(bytes/(1024*1024*1024), 2),             '99990.99') as gbytes
from   (
         select name,
                bytes
         from   v$sgainfo
         union all
         select name, -- Get "Variable Size" stat, not in v$sgainfo    
                value as bytes
         from   v$sga
         where  name = 'Variable Size'
       )        
order by bytes desc;

col name clear
