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
REM #DESC      : Show all information about database links
REM Usage      : Input parameter: none
REM Description: 
REM ------------------------------------------------------------------------------------------------

@plusenv

col owner 	format a12
col db_link 	format a20
col login_name 	format a12
col pwd		format a12
col host 	format a20
col crdate 	format a12
break on owner on db_link
SELECT 	 dl.owner 
	,dl.db_link 
	,dl.username 				login_name 
	,dl.host 
	,to_char(dl.created,'YYMMDD HH24:MI') 	crdate
FROM     dba_db_links	dl
ORDER BY dl.owner
	,dl.db_link
;
