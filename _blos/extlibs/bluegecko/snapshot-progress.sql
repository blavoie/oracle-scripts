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

-- shows the progress of snapshots that are in the middle of refreshing.

column mvowner format a10 
Column mvname format a30 
column refmode format a8 
column refstate format a12 
column inserts format 99999999 
column updates format 999999 
column deletes format 99999 
column event format a30 
column spid format a6 
select  currmvowner_knstmvr mvowner, 
currmvname_knstmvr mvname, 
decode( reftype_knstmvr, 0, 'FAST', 1, 'FAST', 2, 'COMPLETE', REFTYPE_KNSTMVR ) refmode, 
decode(groupstate_knstmvr, 1, 'SETUP', 2, 'INSTANTIATE',3, 'WRAPUP', 'UNKNOWN' ) refstate, 
total_inserts_knstmvr inserts, 
total_updates_knstmvr updates, 
total_deletes_knstmvr deletes, 
b.spid,c.event 
from x$knstmvr X, v$session a, v$process b, v$session_wait c 
WHERE type_knst=6 
and a.paddr = b.addr 
and a.sid = c.sid 
and x.SID_KNST = a.sid 
and x.SERIAL_KNST = a.serial#; 



