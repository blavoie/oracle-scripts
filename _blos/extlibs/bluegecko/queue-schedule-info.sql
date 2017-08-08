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
REM Author      : Murray Ed
REM #DESC       : Information about the current propagation schedules
REM Usage       : No parameters
REM Description : Display information about the current
REM               propagation schedules for aq
REM -----------------------------------------------------

@plusenv

column destination format a15
select total_msgs,jobno, name,destination,instance,disabled,process_name
,failures, TO_CHAR(last_run,'DD HH24:MI:SS') last, TO_CHAR(next_run,'DD HH24:MI:SS') next
from sys.obj$,sys.aq$_schedules
where sys.obj$.oid$ (+) =  sys.aq$_schedules.oid
order by name
/
