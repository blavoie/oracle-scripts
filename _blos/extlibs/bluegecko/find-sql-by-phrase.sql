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

REM -----------------------------------------------------                                                                     
REM Author      : Unknown
REM Modified by : Murray, Ed
REM #DESC       : find info about given sql (partial statement is acceptable)
REM Usage       : stmt - sql statement (partial is acceptable)
REM Description :
REM -----------------------------------------------------                                                                     

undefine stmt;

accept stmt prompt 'Enter string to search for: ';

set lines 200

col module format a25
col osuser format a8
col machine format a10
col program format a40
col sql_text format a80
set trunc off
break on machine skip 1 on osuser on process


-- order by s.machine, s.osuser, s.process;                                                                                   

select t.hash_value, t.module, t.sql_text
from v$sqlarea t
where UPPER(t.sql_text) like UPPER('%&&stmt%')
/

undefine stmt;
