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

column parameter_root  Heading "Monitor"   format a40
column Parameter_name  Heading "Parameter" format a40
column parameter_value Heading "Value"     format a15
TTITLE LEFT v_database ':  Monitoring Default Parameters  -  ' v_dt SKIP 2

select parameter_root
      ,parameter_name
      ,parameter_value
from   bg_parameters
where  parameter_target = 'DEFAULT'
order by parameter_root
        ,LTRIM(LTRIM(parameter_name,'WARN'),'ALARM') || SUBSTR(parameter_name,1,2)
        ,parameter_value
/


column parameter_target format a30

TTITLE LEFT 'Modified Monitoring Parameters'  SKIP 2

select parameter_root
      ,parameter_name
      ,parameter_target
      ,parameter_value
from   bg_parameters
where  parameter_target != 'DEFAULT'
and    set_from_default = 'NO'
order by parameter_root
        ,LTRIM(LTRIM(parameter_name,'WARN'),'ALARM') || SUBSTR(parameter_name,1,2)
        ,parameter_value
/


