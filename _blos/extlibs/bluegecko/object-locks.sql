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
prompt === locked objects by blockers and waiters (object-locks.sql) ===;

col sidser    	format a13		head '   Sid-Ser'
col log   	format 9999		head 'Log|IOs'
col undo	format a09		head 'RB-Blks'
col orauser    	format a07		head 'Oracle|User'	trunc
col sqlhash	format 9999999999 	head 'Prev|SQL Hash'
col hash        format 9999999999       head 'SQL Hash'
col cmnd	format a06		head 'Cmnd'		trunc 
col module	format a26 		head 'Module'		trunc
col sta   	format a1		head 'S'		trunc
col typ    	format a2		head 'Lk|Tp'
col hldreq	format a3		head 'H-R'
col lmode	format 9		head 'L'
col request	format 9		head 'R'
col res		format a18		head 'Resource'
col wrow	format 999		head 'Wt|Row'
col wfile	format 999		head 'Wait|File'
col wblk	format 99999		head 'Wait|Blk'
col wobj	format 99999		head 'Wait|Obj'
col ctime	format 99999		head 'Conv|Secs'
col lwt		format a1		head 'L|W'
col hldreq	format a3		head 'H-R'
col lkids    	format a14		head 'Id1-Id2'
col obj    	format a37		head 'Object Name'
col lmode	format 9		head 'L'
col blk		format a01		head 'B'
col ltyp    	format a2		head 'Lk|Tp'

break on sidser on logontm on orauser on sqlhash on module on hldreq on blk on res on obj
SELECT 	 /*+ RULE */
	 decode(l.block,1,'   '||lpad(l.sid,4,' ')||'-'||lpad(s.serial#,5,' '),'   '||lpad(l.sid,4,' ')||'-'||lpad(s.serial#,5,' ')) sidser
	,to_char(s.logon_time,'MMDD HH24MI')					logontm
	,substr(s.username,1,6)                             			orauser
	,s.prev_hash_value							sqlhash
	,s.sql_hash_value                                                           hash
        ,s.module								module
	,l.lmode||'-'||l.request						hldreq
	,decode(l.block,0,' ','>')						blk
	,l.type||':'||l.id1||'-'||l.id2						res
	,l.ctime								ctime
	,decode(l.id2,0,substr(o.owner,1,6)||'.'||substr(o.object_name,1,30),' ')	obj
FROM	 
	 dba_objects		o
	,v$session		s
        ,v$lock			l
WHERE 	
	 l.sid in
	(SELECT sid from v$lock where block > 0 or request > 0)
AND	 l.sid		= s.sid 
AND	 l.id1		= o.object_id (+)
ORDER BY 
	 l.sid
	,l.ctime	desc
	,l.type
	,l.lmode	desc
;
