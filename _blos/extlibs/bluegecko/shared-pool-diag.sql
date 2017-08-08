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
REM #DESC      : Health check for shared pool problems
REM Usage      : Input parameter: none
REM Description: 
REM ------------------------------------------------------------------------------------------------

-- @plusenv

--------------------------------------------------
prompt
prompt -- shared pool allocation --;
--------------------------------------------------
col name 	format a33
col value 	format a18
SELECT	 name
	,value
FROM	 v$parameter
WHERE	 name in
	('shared_pool_size'
	,'shared_pool_reserved_size'
	,'large_pool_size'
	)
OR	 name 	like '%shared_pool%'
;

--------------------------------------------------
prompt
prompt -- shared pool usage and free space --;
--------------------------------------------------

col name 	format a30
col bytes 	format 9,999,999,999
col mb		format 9,9999.99

SELECT	  
       	 pool
	,round(bytes/(1024*1024),2)	mb
	,bytes
	,name 
FROM 	 v$sgastat
WHERE 	 name 	in 	('free memory'
			,'session heap'
			,'sql area'
			,'library cache'
			,'dictionary cache'
			)
;

--------------------------------------------------
prompt
prompt -- reserve pool statistics --;
--------------------------------------------------

col	fs		format	99,999,999	head 'Free|Spc'
col	afs		format	99,999,999	head 'Free|Avg'
col	fc		format	9999		head 'Free|Cnt'
col	mfs		format	99,999,999	head 'Free|Max'
col	us		format	99,999,999	head 'Used|Spc'
col	aus		format	999,999		head 'Used|Avg'
col	uc		format	9999		head 'Used|Cnt'
col	mus		format	999,999		head 'Used|Max'
col	r		format	99999999	head 'Req'
col	rm		format	999		head 'Miss|Req'
col	lms		format  999999		head 'Miss|Last'
col	mms		format  999999		head 'Miss|Max'
col	f		format	9999		head 'Req|Fai'
col	lfs		format  999,999		head 'Last|Fail|Size'
col	art		format  9999999		head 'Aborted|Req|Threshld'
col	ar		format	999		head 'Ab|Rq'
col	las		format  999999		head 'Last|Abort|Size'

SELECT	 free_space			fs
	,avg_free_size			afs
	,free_count			fc
	,max_free_size			mfs
	,used_space			us
	,avg_used_size			aus
	,used_count			uc
	,max_used_size			mus
	,requests			r
	,request_misses			rm
	,last_miss_size			lms
	,max_miss_size			mms
	,request_failures		f
	,last_failure_size		lfs
	,aborted_request_threshold	art
	,last_aborted_size		las
FROM	 v$shared_pool_reserved
;
