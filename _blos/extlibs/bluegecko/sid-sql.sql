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

--  shows the sql being executed by a particular sid.  Use set-sid.sql to set the sid for this script

set lines 130
col username format a10
col schemaname format a10
col osuser format a8
col machine format a10
col program format a40
col last_command format a10 heading 'Last|Command'
col sql_text format a80
set trunc off
break on machine skip 1 on osuser on process


select t.disk_reads, t.buffer_gets, t.sorts, t.executions, t.sql_text
from 	v$session s,
	v$sqlarea t
where	s.sql_hash_value = t.hash_value
and     s.sid = to_number(nvl(:vsid,s.sid))
order by s.machine, s.osuser, s.process;



