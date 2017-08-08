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
column program_name    format a30 wrap
column comments format a60 wrap
column last_start_date format a30

select owner
      ,job_name
      ,schedule_name
      ,program_name
      ,run_count
      ,failure_count
      ,TO_CHAR(last_start_date,'DD-MON-YYYY HH24:MI:SS') last_start_date
from dba_scheduler_jobs
order by owner, job_name
/
