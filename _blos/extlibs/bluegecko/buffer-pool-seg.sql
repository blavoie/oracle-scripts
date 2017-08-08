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
REM #DESC      : Buffer breakdown by segment for a given buffer pool
REM Usage      : Input parameter: bp_name (default|keep|recycle) & size of object in mb
REM Description: 
REM ------------------------------------------------------------------------------------------------

@plusenv
accept bp_name 		prompt 'Buffer Pool Name: '
accept greater_than_mb	prompt 'Object Size (MB) in buffer greater than: '

prompt
prompt -- Buffer Pool Breakdown By Segment --;

col obj_name 	format a40 trunc	head 'Owner.Object Name'
col obj_type 	format a01 trunc	head 'T'
col tsname  	format a27 trunc	head 'Tablespace Name'
col bfrpool  	format a01		head 'B|P'	trunc
col pf		format 99
col fl 		format 9
col obj_size 	format 999999		head 'Obj Sz|in MB'
col ext		format 9999		head 'Ext'
col bufsz 	format 9999		head 'Bfr Sz|in MB'
col obj_blks 	format 99999999		head 'Num of|Blocks'
col bufcnt	format 999999		head 'Num of|Buffers'
col spct 	format 999.99		head 'Pct of|Object'
col tpct 	format 999.99		head 'Pct of|Tot Bfr'
col avgtch	format 9999		head 'Avg|Tchd'
col maxtch	format 9999		head 'Max|Tchd'

compute sum of bufcnt on report
compute sum of bufsz on report
compute sum of tpct on report
break on report

SELECT 	 o.owner||'.'||o.object_name		obj_name
	,o.object_type				obj_type
	,s.freelists				fl
	,s.extents				ext
	,s.tablespace_name			tsname
	,s.blocks				obj_blks
	,s.bytes/(1024*1024)			obj_size
	,bh.bfc					bufcnt
	,bh.bfc*100/s.blocks 	 		spct 
	,(8192*bh.bfc)/(1024*1024)	bufsz
	,(bh.bfc/tbf.totbufcnt)*100 	 	tpct
	,bh.atch				avgtch
	,bh.mtch				maxtch
FROM 	 (select 	/*+ NO_MERGE */
			 obj
			,count(*) 		bfc 
			,avg(tch)		atch
			,max(tch)		mtch
	  from 		 x$bh  		
	  group by 	 obj)								bh
	,(SELECT buffers totbufcnt from v$buffer_pool where name=upper('&&bp_name')) 	tbf
	,dba_objects									o
	,dba_segments									s
WHERE    o.data_object_id 			= bh.obj (+)
AND      o.owner 				= s.owner
AND      o.object_name 				= s.segment_name
AND      o.object_type 				= s.segment_type
AND 	 buffer_pool 				in (upper('&&bp_name'))
AND	 (8192*bh.bfc)/(1024*1024) 	> &greater_than_mb
ORDER BY bufcnt 
/

undef bp_name
undef greater_than_mb

prompt
prompt -- Buffer Pool Statistics --;
@buffer-pool-stat
