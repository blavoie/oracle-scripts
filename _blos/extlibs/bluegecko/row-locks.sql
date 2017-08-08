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


prompt
prompt
prompt === lock waits (row-locks.sql) ===;


@plusenv

SELECT 	 /*+ RULE */
	 decode(block,1,'>  '||lpad(l.sid,4,' ')||'-'||lpad(s.serial#,5,' '),' < '||lpad(l.sid,4,' ')||'-'||lpad(s.serial#,5,' ')) sidser
	,s.status								sta
	,s.sql_hash_value							sqlhash
	,s.osuser								osuser
        ,s.module                                                               module
--	,substr(s.machine,1,instr(s.machine,'.')-1)       			mach
	,s.process								cpid
	,l.type||':'||l.id1||'-'||l.id2						res
	,l.lmode||'-'||l.request						hldreq
	,l.ctime								ctime
	,s.row_wait_obj#||' '||s.row_wait_file#||'-'||s.row_wait_block#||'-'||s.row_wait_row# ofbr
	,substr(o.owner,1,6)||'.'||substr(o.object_name,1,30)			object
FROM	 
	 dba_objects	o
	,v$session	s
        ,v$lock		l
WHERE 	(l.block 	> 0
     OR  l.request 	> 0
	)
AND	 l.sid			= s.sid 
AND	 s.row_wait_obj#	= o.object_id (+)
ORDER BY l.type
	,l.id1
	,l.id2
	,l.block desc
	,l.ctime desc
;
ttitle off





