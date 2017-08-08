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
column owner           format a15 wrap
column schedule_name   format a30 wrap

select owner
      ,job_name
      ,session_id sid
      ,slave_process_id slave_pid
      ,slave_os_process_id os_pid
      ,running_instance
      ,elapsed_time
      ,cpu_used
from dba_scheduler_running_jobs
order by owner, job_name
/
