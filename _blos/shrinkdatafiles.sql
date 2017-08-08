column smallest   format 999,990
column currsize   format 999,990
column savings    format 999,990
column file_name  format a50 word_wrapped

break on report
compute sum of savings on report

select file_name,
       ceil((nvl(hwm,1)*dbats.block_size)/1024/1024)       as smallest,
       ceil(blocks*dbats.block_size/1024/1024)             as currsize,
       ceil(blocks*dbats.block_size/1024/1024) 
         - ceil((nvl(hwm,1)*dbats.block_size)/1024/1024)   as savings,
       'ALTER DATABASE DATAFILE ''' || file_name || ''' RESIZE ' || ceil( (nvl(hwm,1)*dbats.block_size)/1024/1024 ) || 'M;' 
                                                           as shrink_datafiles
from   dba_data_files  dbadf,
       dba_tablespaces dbats, 
       (
         select file_id, 
                max(block_id+blocks-1) hwm 
         from   dba_extents 
         group by file_id 
       ) dbafs
where  dbadf.tablespace_name = dbats.tablespace_name
and    dbadf.file_id = dbafs.file_id(+);

-- cleanup
clear breaks
clear computes

column smallest   clear
column currsize   clear
column savings    clear
column file_name  clear

