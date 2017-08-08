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
REM #DESC      : Show job information for jobs matching a given "what" pattern
REM Usage      : Input parameter: what_pattern
REM Description: List all dbms_jobs whose "what" value matches the specified pattern
REM ------------------------------------------------------------------------------------------------

@plusenv
undef what_pattern

col job 	format 9999999
col sid 	format 9999
col b 		format a1
col fa 		format 99
col min 	format 9999
col last_date 	format a09
col next_date 	format a09
col interval 	format a35
col owner 	format a06	trunc
col what 	format a50 	word_wrapped

SELECT	 /*+ RULE */
	 j.job 
	,jr.sid
	,to_char(j.last_date,'MMDD HH24MI') 	last_date
	,to_char(j.next_date,'MMDD HH24MI') 	next_date
	,j.broken 				b
	,j.failures 				fa
	,j.interval
	,round((j.next_date - sysdate)*24*60) 	min
	,j.schema_user 				owner
	,j.what
FROM	 dba_jobs_running jr
        ,dba_jobs	  j
WHERE	 j.job 		= jr.job (+)
AND	 lower(what)	like lower('%&&what_pattern%')
ORDER BY 
	 j.broken
	,j.failures
	,min		desc
	,jr.sid		desc
;
undef what_pattern
