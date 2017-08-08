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

@plusenv

column warn_pct format 999 heading "Warn|Pct."
column alarm_pct format 999 heading "Alarm|Pct."
column percent_used format 999 heading "Pct.|Used"

accept v_rsrc PROMPT 'Get data for which resource? (open_cursors, sessions, processes) (Default = ALL): ' DEFAULT NULL
accept v_days PROMPT 'Get resource info. for how many days? (Default = All of ''em!): ' DEFAULT NULL

set feedback off;

select instance_name
      ,resource_name
      ,sample_date
      ,resources_used
      ,resource_limit
      ,percent_used
      ,resource_warn_pct warn_pct
      ,resource_alarm_pct alarm_pct
from bg_resource_usage_hist
where (&&v_days IS NULL OR sample_date >= sysdate - &&v_days)
and   (('&&v_rsrc' = 'NULL') OR (UPPER(resource_name) = UPPER('&&v_rsrc')))
and   ((percent_used > resource_warn_pct) OR (percent_used > resource_alarm_pct))
order by resource_name, sample_date
/
