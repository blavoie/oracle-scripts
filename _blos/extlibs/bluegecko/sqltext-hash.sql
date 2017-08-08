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
REM #DESC      : Full sql text and execution plan given a hash value
REM Usage      : Input parameter: sql_hash_value
REM Description: 
REM ------------------------------------------------------------------------------------------------

@plusenv
undef sql_hash_value

col hash_value  format 99999999999
col sql_text	format a64 word_wrapped
break on hash_value

SELECT	 
	 t.sql_text
FROM 	 v$sqltext t 
WHERE 	 t.hash_value = &&sql_hash_value
ORDER BY t.piece
;

SET ECHO OFF
SELECT LPAD( '  ', 2 * ( LEVEL - 1 ) ) || 
       DECODE( id, 0, operation || '  (Cost = ' || position || ')',
       LEVEL - 1 || '.' || NVL( position, 0 ) || 
       '  ' || operation || 
       '  ' || options ||
       '  ' || object_name ||
       '  ' || object_node ) "Query Plan"
FROM (select distinct id,parent_id, operation,cost, position,options,object_name,object_node
      FROM v$sql_plan 
      where hash_value = '&&sql_hash_value')
START WITH id = 0
CONNECT BY PRIOR id = parent_id
/

undef sql_hash_value








