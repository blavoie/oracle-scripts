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
REM #DESC      : Show statistics for all buffer pools
REM Usage      : 
REM Description: 
REM ------------------------------------------------------------------------------------------------

@plusenv

col name		format a04		head 'Bfr|Pool' 	trunc
col bufmb		format 99,999		head 'Size|MB'
col buffers		format 9,999,999	head 'Num|Blocks'
col lru			format 999		head 'LRU'
col hitr		format 999.99999	head 'Hit|Ratio'
col lrucnt		format 99999999		head 'LRU|List'
col dirtycnt		format 99999999		head 'Dirty|List'
col fbw			format 99999		head 'Free|Bfr|Wait'
col wrt			format 99999999		head 'Write|Compl|Wait'
col bfr			format 999999999	head 'Buffer|Busy|Wait'
col fbi			format 999999999	head 'Free|Bfr|Insp'
col dbi			format 999999999	head 'Dirty|Buffer|Insp'
col dbcK		format 9999999		head 'Block|Changes|/1000'
col lrdsK		format 99999999		head 'Logi|Reads|/1000'
col prdsK		format 9999999		head 'Phys|Reads|/1000'
col pctprds		format 999		head 'Pct|Phy|Rds'
col pwrtK		format 9999999		head 'Phys|Wrts|/1000'
col pctpwrt		format 999		head 'Pct|Phy|Wrt'

break on report
compute sum of buffers on report
compute sum of bfrmb on report
compute sum of lru on report

SELECT	 bp.name
	,bp.buffers			buffers	
	,bp.set_count			lru
	,(bs.blksize*bp.buffers)/(1024*1024)		bufmb
	,((db_block_gets+consistent_gets) - physical_reads) * 100 / (decode(db_block_gets,0,1,db_block_gets)+consistent_gets)	hitr
	,free_buffer_wait		fbw
	,dirty_buffers_inspected	dbi
	,write_complete_wait		wrt
	,buffer_busy_wait		bfr
	,free_buffer_inspected		fbi
	,db_block_change/1000		dbcK
	,(db_block_gets+consistent_gets)/1000	lrdsK		
	,physical_reads/1000		prdsK
	,physical_reads*100/decode(tbps.tprds,0,1,tbps.tprds)  pctprds
	,physical_writes/1000		pwrtK
	,physical_writes*100/decode(tbps.tpwrt,0,1,tbps.tpwrt)  pctpwrt
FROM	 v$buffer_pool_statistics	bps
	,v$buffer_pool			bp
	,(SELECT sum(db_block_gets+consistent_gets) tlrds, sum(physical_reads) tprds, sum(physical_writes) tpwrt 
	  FROM   v$buffer_pool_statistics) tbps
	,(SELECT value blksize   from v$parameter where name='db_block_size') bs
WHERE	 bp.id	= bps.id
ORDER BY bp.name
;
