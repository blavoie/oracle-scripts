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

REM ------------------------------------------------------------------------------------------------
REM Usage      : Input parameter: none
REM Description: Show blocking session waiting sessions.  Blocking session info is preceded with  a ">"
REM              wating session info is preceded with a "<"
REM ------------------------------------------------------------------------------------------------

@plusenv
set lines 200
col sidser    	format a15		head '><    Sid-Ser-S'
col lhhmm   	format a04		head 'Logn|Time'
col orauser    	format a06		head 'Ora|User'		trunc
col osuser    	format a06		head 'OS|User'		trunc
col sqlhash	format a10        	head 'SQL Hash'
col prevhash        format a10              head 'Prev Hash'
col module	format a17 		head 'Module'		trunc
col mach   	format a12    		head 'Machine'		trunc
col sp		format a10 		head 'Svr-Pgm'
col hr		format a02		head 'HR'
col res		format a18		head 'Resource'
col ctime	format a04		head 'Ctim'
col lcall	format a04		head 'Last|Call|Elap'
col obj    	format a20		head 'Locked Object'
col object_name format a30              head 'object name'
break on res skip 1

SELECT 	 /*+ RULE */
	 decode(l.block,0,' ','>')||decode(s.lockwait,null,' ','<')||lpad(l.sid,5,' ')||','||
	 lpad(s.serial#,5,' ')||'-'|| substr(s.status,1,1)							sidser
	,to_char(s.logon_time,'HH24MI')										lhhmm
	,substr(s.username,1,6)                             							orauser
	,to_char(sql_hash_value)										sqlhash
	,to_char(prev_hash_value)                                                                               prevhash
        ,s.module												module
	,s.osuser												osuser
	,p.spid||'-'||substr(nvl(p.program,'null'),instr(p.program,'(')+1,4)					sp
	,substr(s.machine,1,instr(machine,'.')-1)       							mach
	,decode(l.block,0,' '||to_char(l.request),to_char(lmode)||' ')						hr
	,l.type||':'||l.id1||'-'||l.id2										res
	,lpad(decode(sign(999-s.last_call_et),-1,round(s.last_call_et/60)||'m'
	                                     ,to_char(s.last_call_et)||'s'),4,' ') 				lcall
	,lpad(decode(sign(999-l.ctime),-1,trunc(l.ctime/60)||'m',to_char(l.ctime)||'s'),4,' ')			ctime
	,decode(l.id2,0,to_char(l.id1)
		       ,s.row_wait_obj#||')'||s.row_wait_file#||'-'||s.row_wait_block#||'-'||s.row_wait_row#)	obj
       ,dba_objects.object_name
FROM	 
	 v$process		p
	,v$session		s
        ,v$lock			l
        ,dba_objects
WHERE 	
	(l.block 	> 0 or l.request > 0)
AND	 l.sid		= s.sid  (+)
AND	 s.paddr	= p.addr (+)
AND      dba_objects.object_id = s.row_wait_obj#
ORDER BY 
	 res
	,l.block	desc
	,l.ctime	desc
;
