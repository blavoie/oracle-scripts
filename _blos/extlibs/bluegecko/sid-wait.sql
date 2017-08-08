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

---  shows the event a particular sid is waiting on.  Use set-sid to identify the sid you wish to work with

set lines 130
col username format a10
col schemaname format a10
col osuser format a8
col machine format a10
col event format a30
col status format a6
col prms format a20 wrap
break on machine skip 1 on osuser on process

select s.MACHINE, s.OSUSER, s.PROCESS, s.sid, s.USERNAME, 
	decode(s.STATUS,'INACTIVE',NULL,s.STATUS) status,
	w.event, w.wait_time, w.p1||'-'||w.p2||'-'||w.p3 prms
from v$session s,
	v$session_wait w
where	s.sid = w.sid
and     s.sid = nvl(:vsid,s.sid)
order by s.machine, s.osuser, s.process;
