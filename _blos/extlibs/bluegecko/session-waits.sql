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

-- show information about sessions and what they're waiting on 

@plusenv
col username format a10
col sql_hash_value format 9999999999
col schemaname format a10
col osuser format a8
col machine format a10
col event format a30
col what format a20
col module format a10 
break on machine on osuser on process
set trunc on
col osuser noprint 
col username noprint

select s.MACHINE, s.OSUSER, s.sid,s.serial#, s.PROCESS,  s.USERName, 
	decode(s.STATUS,'INACTIVE',NULL,s.STATUS) status,
	w.event, 
		w.p1||'-'|| w.p2||'-'|| w.p3 what, s.module,s.sql_hash_value
	,logon_time, serial#
	/*ROW_WAIT_OBJ#, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# */
from v$session s,
	v$session_wait w
where   s.sid = w.sid
and     w.wait_time = 0
and	w.event not like 'SQL*N%'
and     w.event not in ('rdbms ipc message','jobq slave wait','pmon timer','smon timer')
order by event, s.machine, s.osuser, s.process
/

