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

set lines 200
set pages 100
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

column event_text format a80
column event_email_text format a80 wrap
column event format a40

select event_date_time initial_event
      ,event_latest_occurrence latest_occurrence
      ,event_occurrences count
      ,event_class || '.' ||event_name event
      ,NVL(event_email_text,event_text) 
       || DECODE(event_class,'MONITOR ERROR', '   Source: ' || source_code_location,'') event_text
FROM   bg_events
WHERE  event_status = 'OPEN'
ORDER BY event_class, event_name, event_date_time;
