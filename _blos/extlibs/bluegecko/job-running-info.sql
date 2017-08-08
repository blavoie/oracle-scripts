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
REM #DESC      : Show session info for all running jobs
REM Usage      : 
REM Description: Session info for running jobs -  server PID, SNP, module, SQL hash value, last call
REM              elapsed time
REM ------------------------------------------------------------------------------------------------

@plusenv

col job 	format 9999999
col orauser    	format a07	trunc
col sidser 	format a10  		head "Sess,Ser#"
col sp		format a10 		head 'SPID-SNP'
col pid		format 9999		head 'Ora|PID'
col hash	format 9999999999	head 'SQL Hash'
col module	format a18	trunc	head 'Module'
col owner 	format a06	trunc
col what 	format a48 	word_wrapped
col idlm   	format 999		head 'Min|Idl'
col logontm   	format a09	trunc	head 'Logon|Time'

SELECT	 /*+ RULE */
	 j.job 
	,s.username 				orauser
	,lpad(s.sid,4,' ')||','||lpad(s.serial#,5,' ')	sidser
	,lpad(p.spid,5,' ')||'-'||substr(nvl(p.program,'null'),instr(p.program,'(')+1,4)	sp
	,s.module 				module
	,s.sql_hash_value			hash
        ,to_char(s.logon_time,'MMDD HH24MI')	logontm
	,s.last_call_et/60     			idlm
	,j.schema_user 				owner
	,j.what
FROM	 dba_jobs_running 	jr
	,v$process		p
	,v$session		s
        ,dba_jobs	  	j
WHERE	 j.job 		= jr.job 
AND	 jr.sid		= s.sid
AND	 s.paddr	= p.addr (+)
ORDER BY s.logon_time
;
ttitle off
