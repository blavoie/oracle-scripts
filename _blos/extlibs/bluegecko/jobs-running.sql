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
REM #DESC      : Show running jobs
REM Usage      : 
REM Description: List all dbms_jobs that are currently running
REM ------------------------------------------------------------------------------------------------

@plusenv

col job 	format 9999999
col sid 	format 99999
col b 		format a1
col fa 		format 99
col min 	format 99999
col last_date 	format a15
col next_date 	format a15
col interval 	format a24
col owner 	format a08
col what 	format a45 word_wrapped

SELECT	 /*+ RULE */
	 j.job 
	,jr.sid
	,to_char(j.last_date,'YYMMDD HH24:MI:SS') last_date
	,to_char(j.next_date,'YYMMDD HH24:MI:SS') next_date
	,j.broken b
	,j.failures fa
	,j.interval
	,round((j.next_date - sysdate)*24*60) min
	,j.schema_user owner
	,j.what
FROM	 dba_jobs_running jr
        ,dba_jobs	  j
WHERE	 j.job 		= jr.job 
AND	 jr.sid		is not null
ORDER BY 
	 j.failures
	,j.broken
	,j.last_date 
;
