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

column Event       Heading "Monitor" format a40
column Scope       Heading "Scope"
column Description Heading "Description"
TTITLE LEFT v_database ':  Installed Monitors  -  ' v_dt SKIP 2

select event_type_scope  Scope
      ,event_class || '.' || event_name event
      ,event_description  Description
from  bg_event_types
order by 1,2
/
      
