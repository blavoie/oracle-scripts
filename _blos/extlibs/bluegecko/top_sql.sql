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

-- get variables
set heading off
set verify off
ttitle off
column v_report_run_id NEW_VALUE v_report_run_id NOPRINT;
column v_start_dt NEW_VALUE v_start_dt NOPRINT;
column v_end_dt   NEW_VALUE v_end_dt   NOPRINT;

select max(report_run_id) v_report_run_id from bg_awr_report_runs
where  report_type = 'AWR'
and    report_format = 'TEXT';

select TO_CHAR(begin_snap_time,'DD-MON-YYYY HH24:MI:SS') v_start_dt
      ,TO_CHAR(end_snap_time, 'DD-MON-YYYY HH24:MI:SS') v_end_dt
from bg_awr_report_runs 
where report_run_id = &&v_report_run_id;


set lines 80
set pages 50000
set heading on

-- undefine v_report_run_id;
TTITLE CENTER 'TOP SQL: ' v_section SKIP 2 CENTER 'Sample_start: '  v_start_dt '   --   Sample End: ' v_end_dt SKIP 2
COLUMN elapsed_seconds FORMAT a12   HEADING 'Elapsed|Seconds'
COLUMN cpu_seconds     FORMAT a12   HEADING 'CPU|Seconds'
COLUMN executions      FORMAT a12   HEADING 'Executions'
COLUMN elapsed_per_execution FORMAT a10 HEADING 'Elapsed|Per Exec.'
COLUMN percent_db_time FORMAT 99.99 HEADING 'Percent|DB Time'
COLUMN sql_id          FORMAT a13   HEADING 'SQL ID'
COLUMN sql_text        HEADING ''
COLUMN plan_text       HEADING ''
COLUMN section NEW_VALUE v_section NOPRINT;
BREAK ON section skip page

select elapsed_seconds
      ,cpu_seconds
      ,executions
      ,elapsed_per_execution
      ,percent_db_time
      ,bg_awr_report_sql_time.sql_id
      ,REPLACE(sql_text,chr(10),NULL) sql_text
      ,plan_text
      ,bg_awr_report_sql_time.section
from bg_awr_report_sql_time  
    ,bg_sql_text
    ,bg_awr_report_sql_plan
    ,bg_sql_plan
where bg_awr_report_sql_time.sql_id    = bg_sql_text.sql_id
and   bg_sql_text.sql_id           = bg_sql_plan.sql_id
and   bg_sql_plan.sql_id           = bg_awr_report_sql_plan.sql_id
and   bg_sql_plan.plan_id          = bg_awr_report_sql_plan.plan_id
and   bg_awr_report_sql_time.report_run_id = &&v_report_run_id
and   bg_awr_report_sql_plan.report_run_id = &&v_report_run_id
order by section, position;

