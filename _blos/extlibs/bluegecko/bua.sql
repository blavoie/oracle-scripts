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

@plusenv
rem  bufull.sql
set linesize 200
ttitle 'Sessions With Probable Full Table Scans'
col module format a30
col pid format 999 heading 'PID'
col sid format 99999 heading 'SID'
col serial# format 99999 heading 'SERIAL|#'
col machine format a9 heading 'MACHINE'
col client format a7 heading 'CLIENT|PROCESS'
col program format a8 trunc heading 'CLIENT|PROGRAM'
col server format a7 heading 'SERVER|PROCESS'
col username format a15 heading 'ORACLE USERID'
col osuser format a8 heading 'OS|USERID'
col batch format a1 heading 'B'
col logical format 999999999 heading 'LOGICAL|READS'
col physical_reads format 99999999 heading 'PHYSICAL|READS'
col logon_time format a8 heading 'LOGON'
col duration format a8 heading 'DURATION'
col log_per_sec format 99999 heading 'LOG|PER|SEC'
col phy_per_sec format 999 heading 'PHY|PER|SEC'
col sql_address format a8 heading 'SQL|ADDRESS'
col sql_hash_value format 9999999999 heading 'SQL|HASH|VALUE'
col audsid format 9999999 heading 'AUDIT|SESSION'
col status format a1 heading 'S'
rem
select decode(s.status,'ACTIVE','A','I') status, 
       s.username,
       s.osuser,
       s.module,
       decode( s.terminal, null, 'B', null ) batch,
       s.machine, 
       decode(p.background,1,p.program,s.program) program,
       s.process client,
       p.spid server,
/*     ( block_gets + consistent_gets ) /
       ( ( sysdate - a.timestamp ) * 86400 ) log_per_sec, */
       block_gets + consistent_gets logical,
/*     physical_reads /
       ( ( sysdate - a.timestamp ) * 86400 ) phy_per_sec, */
       physical_reads,
/*     to_char( trunc(sysdate) + ( sysdate - a.timestamp),
                'hh24:mi:ss' ) duration, 
       to_char( a.timestamp, 'hh24:mi:ss' ) logon_time, */
/*     p.pid, */
       s.sid,
/*     s.serial#, */
/*       s.sql_address  ,
       s.audsid  */
       s.sql_hash_value
  from sys.aud$ a,
       v$process p, v$session s, v$sess_io i
 where i.sid = s.sid
   and s.paddr = p.addr(+)
   and s.audsid = a.sessionid(+)
   and a.action#(+) between 100 and 102
   and s.status = 'ACTIVE'
 order by block_gets + consistent_gets;
