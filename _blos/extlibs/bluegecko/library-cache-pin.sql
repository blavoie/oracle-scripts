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

-- show session information for all sessions holding library cache pins


@plusenv

set lines 140
col sid    	format 99999
col serial 	format 99999
col orausr	format a08		trunc
col osusr	format a08		trunc
col s		format a1		trunc
col username 	format a8
col module 	format a30
col machine 	format a25
col hash	format 9999999999
col prevh	format 9999999999
col clpid  	format 999999
SELECT	 sid			sid
	,serial#		serial
	,username		orausr
	,status			s
	,server
	,module
	,sql_hash_value		hash
	,prev_hash_value	prevh
	,osuser			osusr
	,machine
	,process		clpid
FROM	 v$session
WHERE	 saddr in
(SELECT	 b.kglpnses
 FROM	 x$kglpn		b
 WHERE	 kglpnreq		= 0
 AND	 EXISTS
	(SELECT	 w.kglpnhdl
	 FROM	 x$kglpn	w
	 WHERE	 w.kglpnses	= (select s.saddr from v$session s, v$session_wait w where s.sid=w.sid 
	 			   and w.event = 'library cache pin' and rownum =1)
	 AND	 w.kglpnhdl	= b.kglpnhdl
	 AND	 w.kglpnreq	> 0
	)
)
;
