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


column name format a50
@bigdates
SELECT SUBSTR(name,INSTR(name,'/',-1)+1) name, completion_time 
  FROM   v$archived_log
  WHERE  NVL(backup_count,0) < 1
  AND    status = 'A'
  AND    standby_dest = 'NO'
order by completion_time;
