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

column begin_interval_time format a30
column end_interval_time format a30

column dbid new_value v_dbid NOPRINT;
column instance_number new_value v_inst NOPRINT;

SELECT d.dbid, instance_number
FROM v$database d, v$instance i;


select instance_number,snap_id,begin_interval_time, end_interval_time
from   dba_hist_snapshot
where  instance_number = (select instance_number from v$instance)
and    begin_interval_time > sysdate -1
order by 2
/

accept v_begin prompt 'Please enter beginning snap: ';
accept v_end   prompt 'Please enter ending snap: ';


select output from table(dbms_workload_repository.awr_report_text(&v_dbid,&v_inst,&v_begin, &v_end))
/


