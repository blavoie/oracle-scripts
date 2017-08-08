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

undefine v_job_name;
accept v_job_name prompt 'Get last run info for which job?: '

column additional_info format a80 wrap
column owner format a20;
column job_name format a30;
column status format a10

select log_date
      ,owner
      ,job_name
      ,status
      ,error#
      ,additional_info
from dba_scheduler_job_run_details
where job_name = UPPER('&&v_job_name')
and   log_date = (select max(log_date)
                  from   dba_scheduler_job_run_details
                  where  job_name = UPPER('&&v_job_name'))
/
