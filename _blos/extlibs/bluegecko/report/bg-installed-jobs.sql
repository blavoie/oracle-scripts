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

-- This script shows installed monitors

set heading off
set verify off
ttitle off
column v_database NEW_VALUE v_database NOPRINT;
column v_dt NEW_VALUE v_dt NOPRINT;

column db_unique_name NOPRINT;
select db_unique_name v_database
      ,TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS') v_dt
from v$database;

set lines 150
set pages 50000
set heading on
set feedback off
set trimspool on 

column job_scope  Heading "Scope"   format a8
column Action     Heading "Action"  format a60
column schedule_name Heading "Schedule" format a25
column enabled    Heading "Enabled" format a7
TTITLE LEFT v_database ':  BG Scheduled Jobs  -  ' v_dt SKIP 2



select b.job_scope
      ,lower(b.job_action) Action
      ,b.schedule_name
      ,DECODE(d.enabled,'TRUE','YES','FALSE','NO') enabled
from bg_scheduler_jobs  b 
    ,dba_scheduler_jobs d
where b.job_name = d.job_name
order by b.job_scope desc
        ,lower(b.job_action)
/

