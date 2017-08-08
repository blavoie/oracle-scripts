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

@plusenv

column autoextensible format a15
select t.tablespace_name
      ,ROUND(current_bytes_free/1024/1024)  free_mb
      ,ROUND(bg_space_monitor.ts_daily_growth_rate(t.tablespace_name)/1024/1024) daily_growth_mb
      ,ROUND(bg_space_monitor.ts_percent_full(t.tablespace_name)) percent_full
      ,CASE WHEN ROUND(bg_space_monitor.ts_days_until_full(t.tablespace_name)) < 365 THEN
                 TO_CHAR(ROUND(bg_space_monitor.ts_days_until_full(t.tablespace_name)))
            ELSE '> 1 Year'
       END AS days_until_full
      ,NVL(a.autoextensible,'NO') autoextensible
from bg_ts_info      t
    ,dba_tablespaces d
    ,(select distinct tablespace_name, 'YES' autoextensible from dba_data_files where autoextensible = 'YES') a 
where t.tablespace_name = d.tablespace_name
and   t.tablespace_name = a.tablespace_name (+)
and   contents not in ('UNDO','TEMPORARY')
order by bg_space_monitor.ts_days_until_full(tablespace_name)
        ,tablespace_name
/


