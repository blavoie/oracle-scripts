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

accept v_days PROMPT 'Get lock info. for how many days? (Default = All of ''em!): ' DEFAULT NULL

set feedback off;

column lock_id format 99999999
column blocker format 99999999
column locked_object format a40
column module format a30 wrap
column osuser format a15 wrap
column username format a10 wrap
column blocker heading "Blocking|Lock ID" JUSTIFY LEFT
column lock_id heading "Lock ID"
select l.bg_lock_id lock_id
     , l.blocking_bg_lock_id blocker
     , l.log_date
     , l.osuser
     , l.username
     , l.ctime
     , l.module
from bg_lock_info l
where (&&v_days IS NULL OR l.log_date >= sysdate - &&v_days)
connect by prior l.bg_lock_id = l.blocking_bg_lock_id start with l.blocking_bg_lock_id is null
order by l.log_date
/

