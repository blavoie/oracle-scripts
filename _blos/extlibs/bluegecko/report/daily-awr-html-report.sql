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

-- This script generates an html awr report                                                                                                                  
-- It assumes that a nightly job is scheduled to generate text                                                                                               
-- thus it simply gets the last awr report                                                                                                                   

set heading off
set verify off
ttitle off

set lines 1000
set pages 0
set trimspool on
set feedback off

select text
from   bg_awr_report_text
where  report_run_id =
  (select max(report_run_id)
   from   bg_awr_report_runs
   where  report_type = 'AWR'
   and    report_format = 'HTML'
  )
order by line
/
