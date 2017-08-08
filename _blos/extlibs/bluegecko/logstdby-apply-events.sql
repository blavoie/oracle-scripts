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

-- show logical standby event information

@plusenv
@bigdates

set lines 200
column event format a60 wrap
column status format a60 wrap;
select event_time,event, status_code,status 
from dba_logstdby_events 
order by event_time
/

