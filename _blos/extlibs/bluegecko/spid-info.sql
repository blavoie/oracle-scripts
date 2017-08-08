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
REM #DESC      : Show all session related information for a single session given an SPID
REM Usage      : Input parameter: session_sid
REM Description: 
REM ------------------------------------------------------------------------------------------------

undef session_id
undef mspid

accept mspid prompt 'enter spid: '


@plusenv

COLUMN session_id NEW_VALUE xsid NOPRINT
select sid session_id from v$session
where paddr = (select addr from v$process where spid = &&mspid)
/

set lines 120 pages 0
col colx newline just left  format a120
col coly newline just left  word_wrapped format a120

SELECT	/*+ ORDERED */
         ' '                                    			colx
        ,'Session id ...........:'||s.sid       			colx
        ,'Serial # .............:'||s.serial#   			colx
        ,'Oracle PID ...........:'||p.pid   				colx
        ,'SADDR ................:'||s.saddr 				colx
        ,'Oracle logon id ......:'||s.username  			colx
        ,'Logon time ...........:'||to_char(logon_time,'YYYY-MM-DD/HH24:MI:SS')	colx
        ,'Current time .........:'||to_char(sysdate,'YYYY-MM-DD/HH24:MI:SS')	colx
        ,'Session status .......:'||s.status    			colx
        ,'Server type ..........:'||s.server    			colx
        ,'Process type .........:'||substr(p.program,instr(p.program,'('),12) 	colx
        ,' '                                    			colx
        ,'Logical reads ........:'||(i.block_gets+i.consistent_gets)    colx
        ,'Physical reads .......:'||i.physical_reads                    colx
        ,'Block Changes ........:'||i.block_changes                    	colx
        ,'Consistent Changes ...:'||i.consistent_changes                colx
        ,'Last call elapsed min :'||round(s.last_call_et/60)            colx
        ,' '                                    			colx
        ,'OS logon id ..........:'||s.osuser    			colx
        ,'OS server PID ........:'||p.spid      			colx
        ,'OS parent PID ........:'||s.process   			colx
        ,'OS machine ...........:'||s.machine   			colx
        ,' '                                    			colx
        ,'Module ...............:'||s.module    			colx
        ,'Program ..............:'||s.program   			colx
        ,'SQL hash value .......:'||s.sql_hash_value    		colx
        ,'Prev SQL hash value ..:'||s.prev_hash_value    		colx
	,'First load time ......:'||sq.first_load_time			colx
        ,' '                                    			colx
        ,'Executions ...........:'||sq.executions       		colx
	,'Parse calls ..........:'||sq.parse_calls			colx
        ,'Sorts ................:'||sq.sorts    			colx
        ,'Version count ........:'||sq.version_count   			colx
        ,'Buffer gets per SQL ..:'||round(sq.buffer_gets/decode(sq.executions,0,1,sq.executions)) colx
        ,'Disk reads per SQL ...:'||round(sq.disk_reads/decode(sq.executions,0,1,sq.executions))  colx
        ,' '                                    			colx
        ,'Waiting for lock .....:'||decode(s.lockwait,null,'NO','YES')  colx
        ,'Wait Obj-File-Blk-Row :'||row_wait_obj#||'-'||row_wait_file#||'-'||row_wait_file#||'-'||row_wait_row# colx
        ,' '                                    			colx
        ,'SQL text .............:'              			colx
        ,sq.sql_text                                    		coly
FROM
         v$session     s
        ,v$process     p
        ,v$sess_io     i
        ,v$sqlarea     sq
WHERE
         s.sid          = &&xsid
AND      s.paddr	= p.addr (+)
AND      s.sid          = i.sid (+)
AND      s.sql_address  = sq.address (+)
AND      decode(sign(s.sql_hash_value),-1,s.sql_hash_value+power(2,32),sql_hash_value) = sq.hash_value (+)
;

@plusenv
prompt
prompt --- Session Wait ---;
col sid	   format 9999  			heading "Ses|Id"
col cnt	   format 9999  		heading "Cnt"
col event  format a26  			heading "Wait Event" trunc
col state  format a10  			heading "Wait State" trunc
col siw    format 999999  		heading "Wt So|Far-ms"
col wt     format 999  			heading "Wt|ms"
col p1txt  format a14			trunc
col p1     format 99999999999999999  		heading "P1"
col p2txt  format a12			trunc
col p2     format 99999999999999999  		heading "P2"
col p3txt  format a08			trunc
col p3     format 999999  		heading "P3"

SELECT 	 sid
	,seq#	cnt
	,event
	,p1text p1txt
       	,p1 
       	,state
       	,seconds_in_wait siw
	,p2text p2txt
	,p2 
	,p3text p3txt
	,p3
FROM   	 v$session_wait
WHERE	 sid = &&xsid
;


prompt
prompt --- Open Cursors ---;
select hash_value, sql_text 
from v$open_cursor 
where sid = &&xsid
order by sql_text
;


prompt
prompt --- Lock Info ---;
col towner	format a06	heading 'Table|Owner'	truncated
col ctime	format 999	heading 'Cnv|Sec'
col tname	format a30	heading 'Table Name'
col type	format a02	heading 'Lk|Tp'
col commnd	format a08	heading 'Commnd'	truncated 
col mheld	format a08	heading 'Mode|Held'	truncated
col x		format a01	heading 'X'
col mreq	format a08	heading 'Mode|Req'	truncated
col sid		format 9999	heading 'Sess|Id'
col ser      	format 99999	heading 'Ser|No'
col orauser    	format a06	heading 'Oracle|User'	truncated
col shadow   	format a5    	heading 'Shado'
col sqlhash	format 9999999999 head 'SQL|Hash Value'
col module	format a13 	head 	'Module'	truncated
col mach	format a13 	head 	'Machine'	truncated
col parent   	format a5				truncated
col osuser   	format a07				truncated
col sta   	format a3 				truncated

break on sid on ser on orauser on shadow on sqlhash on module on mach on towner on tname on type on ctime

SELECT   /*+ RULE */                                                                       
	 unique
	 l.sid 					sid
	,s.serial#  				ser
	,s.username 				orauser
	,p.spid     				shadow
	,s.sql_hash_value			sqlhash
	,s.module				module
	,substr(s.machine,1,instr(machine,'.')-1)       mach
 	,u.name 				towner
        ,o.name					tname
	,l.type					type
	,l.ctime 				ctime
       	,decode (s.command
	       , 0, 'NO CMD'
	       , 1, 'CR TB'
               , 2, 'INSERT'
	       , 3, 'SELECT'
	       , 4, 'CR CL'
	       , 5, 'AL CL'
	       , 6, 'UPDATE'
	       , 7, 'DELETE'
	       , 8, 'DR'
	       , 9, 'CR IX'
	       ,10, 'DR IX'
	       ,11, 'AL IX'
	       ,12, 'DR TB'
	       ,15, 'AL TB'
	       ,17, 'GRANT'
	       ,18, 'REVOKE'
	       ,19, 'CR SYN'
	       ,20, 'DR SYN'
	       ,21, 'CR VIEW'
	       ,22, 'DR VIEW'
	       ,26, 'LOCK TB'
	       ,27, 'NO OP'
	       ,28, 'RENAME'
	       ,29, 'COMMENT'
	       ,30, 'AUDIT'
	       ,31, 'NOAUDIT'
	       ,32, 'CR DBLK'
	       ,33, 'DR DBLK'
	       ,34, 'CR DB'
	       ,35, 'AL DB'
	       ,36, 'CR RBS'
	       ,37, 'AL RBS'
	       ,38, 'DR RBS'
	       ,39, 'CR TS'
	       ,40, 'AL TS'
	       ,41, 'DR TS'
	       ,42, 'AL SES'
	       ,43, 'AL UER'
	       ,44, 'COMMIT'
	       ,45, 'ROLBCK'
	       ,46, 'SAVEPT'
	       ,62, 'ANA TB'
	       ,63, 'ANA IX'
	       ,64, 'ANL CL'
	       ,85, 'TRC TB'
	       ,    '?'
	       )               			commnd
	,decode((l.lmode||s.command),23,'x','-') x
	,decode(l.lmode,                                                                  
		0, '    ',           /* Mon Lock equivalent */                                
		1, 'Null',           /* N */                                                  
		2, 'Row-S SS',     /* L */                                                  
		3, 'Row-X SX',     /* R */                                                  
		4, 'Share',          /* S */                                                  
		5, 'S/Row-X SSX',  /* C */                                                  
		6, 'Exclusive',      /* X */                                                  
		'Invalid') 			mheld
--,s.lockwait
--,l.id1
--,l.id2
         ,decode(l.request,                                                        
		0, '    ',           /* Mon Lock equivalent */                                
		1, 'Null',           /* N */                                                  
		2, 'Row-S SS',     /* L */                                                  
		3, 'Row-X SX',     /* R */                                                  
		4, 'Share',          /* S */                                                  
		5, 'S/Row-X SSX',  /* C */                                                  
		6, 'Exclusive',      /* X */                                                  
		'Invalid') 			mreq
FROM
	 v$session s 
     	,v$process p 
 	,sys.user$ u                                            
	,sys.obj$  o  
      	,v$lock    l 
      	,v$locked_object    lo 
WHERE	 l.sid 		= s.sid
AND      l.sid 		= lo.session_id
AND      lo.session_id	= s.sid
AND	 lo.object_id	= o.obj#
AND      o.owner# 	= u.user#                                                  
AND   	 s.paddr 	= p.addr 
AND   	 l.type 	in ('TM','TX','ST')
AND	 l.sid 		= &&xsid
ORDER BY 
	 l.sid
	,o.name
	,l.type
;


prompt
prompt --- RBS Info ---;
col name 	format a6 	trunc
col st 		format a1 	trunc
col sst 	format a1 	trunc
col no 		format 99 	trunc
col xacts 	format 0 	heading X
col sid 	format 99999	heading SID
col osid 	format a7 	trunc
col oraid 	format a7	trunc
col lioh  	format 999	heading 'Log|IOh'
col phyio   	format 99999	heading 'PhyIO'
col ublks   	format 99999	heading 'Undo'
col rsmb 	format 9999 	heading CUR
col optmb 	format 999 	heading OPT
col hwm 	format 9999 	heading HWM
col ext 	format 99 	heading EX
col max 	format 999 	heading MAX
col getsK 	format 9999
col wrtsK 	format 9999999
col wai 	format 9999
col wrp 	format 999
col xt 		format 999
col sh 		format 99
col avgactK 	format 999999
col starttm	format a11	trunc heading 'Start Time'

break on name on st on no on xacts on rsMB on optMB on hwm on ext on max on getsK on wrtsK on avgactK on wai on wrp on xt on sh
SELECT  /*+ RULE */
	 rn.name
	,decode(rs.status,'ONLINE','O','OFFLINE','X','FULL','F','PENDING OFFLINE','P','?') 		st
	,rs.usn 		no
	,xacts			xacts
	,rssize/(1024*1024) 	rsMB
	,optsize/(1024*1024) 	optMB
	,hwmsize/(1024*1024) 	hwm
	,extents		ext
	,decode(sign(999 - dr.max_extents),-1,999,dr.max_extents) max
	,gets/1024 		getsK
	,writes/1024 		wrtsK
	,aveactive/1024 	avgactK
	,waits 			wai
	,wraps 			wrp
	,extends 		xt
	,shrinks 		sh
	,s.sid 			sid
	,s.osuser 		osid
	,s.username 		oraid
	,to_char(to_date(t.start_time,'MM/DD/YY HH24:MI:SS'),'MM/DD HH24:MI') starttm
	,decode(s.status,'ACTIVE','x',' ') sst
	,round(t.log_io/(100))	lioh
	,t.phy_io		phyio
	,t.used_ublk		ublks
FROM	 v$session 		s 
     	,v$rollstat 		rs
	,v$rollname 		rn
	,dba_rollback_segs 	dr
	,v$transaction 		t
WHERE	 rs.usn (+) = rn.usn
AND 	 rs.usn = dr.segment_id
AND 	 t.addr = s.taddr (+)
AND 	 t.xidusn (+) = rn.usn
AND	 s.sid		= &&xsid
;
undef session_id
