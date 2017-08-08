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

--- generate statements to turn tracing on for a particular sid


accept sid prompt 'Enter sid :'
set head off
set lines 140
set veri off
set feed off

prompt
prompt **** SQL generated into to.sql ****
prompt

spool to.sql

select 'exec sys.dbms_system.set_ev('||to_char(s.sid)||','||to_char(s.serial#)||
	',10046,12,''' || ''');' sqlt
from v$session s
where sid  IN (&sid)
/

spool off

set head on
set feed on


