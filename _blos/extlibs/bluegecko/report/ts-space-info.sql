/*
Copyright (c) 2007 Blue Gecko, Inc
License:

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

-- This script shows space consumed and projections for tablespaces                                                                                          
-- Note that if the average daily growth is 0 or less than 0 we use a                                                                                        
-- value of 1 mb per day.   Note also, average daily growth could be less                                                                                    
-- than 0 due to purging of data, dropping a table, etc.                                                                                                     
set heading off
set verify off
ttitle off
column v_database NEW_VALUE v_database NOPRINT;
column v_dt NEW_VALUE v_dt NOPRINT;

column name NOPRINT;
select instance_name v_database
      ,TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS') v_dt
from v$instance;

set lines 100
set pages 50000
set heading on
set feedback off
set trimspool on 

column tablespace_name heading "Tablespace"
column consumed        heading "Consumed MB"
column available       heading "Available MB"
column allocated       heading "Allocated MB"

TTITLE LEFT v_database ':  Space Utilization  -  ' v_dt SKIP 2

select consumed.tablespace_name, allocated, consumed, available
FROM
(select ROUND(sum(bytes)/1024/1024,0) consumed, tablespace_name
from dba_segments group by tablespace_name) consumed
,(select ROUND(sum(bytes)/1024/1024,0) available, tablespace_name
from dba_free_space group by tablespace_name) available
,(select ROUND(sum(bytes)/1024/1024,0) allocated, tablespace_name
from dba_data_files group by tablespace_name) allocated
where consumed.tablespace_name = allocated.tablespace_name
and   allocated.tablespace_name = available.tablespace_name
and   consumed.tablespace_name = available.tablespace_name
order by tablespace_name
/
