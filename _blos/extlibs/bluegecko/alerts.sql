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

set heading off
select  'Event Class.Name:      ' || event_class || '.' ||event_name  || chr(10)
      ||'Initial Event:         ' || event_date_time || chr(10)
      ||'Latest Occurrence:     ' ||  event_latest_occurrence || chr(10)
      ||'Number of Occurrences: ' || event_occurrences || chr(10)
      ||'Event Severity:        ' || event_severity_code || chr(10)
      ||'Event Text:            ' || NVL(event_email_text,event_text) || DECODE(event_class,'MONITOR ERROR', '   Source: ' || source_code_location,'') || chr(10)     
FROM   bg_alerts
WHERE  event_status = 'OPEN'
ORDER BY event_class, event_name, event_date_time;
