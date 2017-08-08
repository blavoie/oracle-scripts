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

-- This script shows daily monitoring events

set heading off
set verify off
ttitle off
column v_database NEW_VALUE v_database NOPRINT;
column v_title  NEW_VALUE v_title NOPRINT;

column db_unique_name NOPRINT;
select db_unique_name v_database
      ,'BG Events For ' || TO_CHAR(TRUNC(sysdate-1),'DD-MON-YYYY HH24:MI') || ' Through ' 
       || TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY HH24:MI') v_title
from v$database;

set lines 150
set pages 50000
set heading on
set feedback off
set trimspool on 

clear columns
column Event   Heading "Event Name"   format a30
column event_class Heading "Event Class" format a20
column event_status Heading "Status" format a8
column event_id     JUSTIFY  LEFT Heading "Event ID" format 99999999 
column event_text   format a80 FOLD_BEFORE HEADING "" word_wrapped


TTITLE LEFT v_database ': ' v_title  SKIP 2

select event_id
      ,event_status
      ,event_class 
      ,event_name Event
      ,event_text event_text
from bg_events 
where event_date_time > TRUNC(SYSDATE -7)
and   event_date_time <= TRUNC(SYSDATE)
and   event_class != 'MONITOR ERROR'
/

