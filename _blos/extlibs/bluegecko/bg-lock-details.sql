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

accept v_lock_id PROMPT 'Get details for which lock id? (Default = latest): ' DEFAULT NULL

set feedback off;

column v_lock_id new_value v_lock_id noprint;

select NVL(&&v_lock_id,MAX(bg_lock_id)) v_lock_id
from  bg_lock_info
where blocking_bg_lock_id is null;

column lock_id format 99999999
column blocker format 99999999
column locked_object format a40
column module format a30 wrap
column osuser format a15 wrap
column username format a10 wrap
column locked_object heading "Locked Object(s)"
column blocked_object heading "Blocked Object(s)"
column lsql heading "Possible Locking SQL"
column bsql heading "Possible Blocked SQL"

select 'Blocker > ' action
     , l.bg_lock_id id
     , l.log_date
     , l.osuser
     , l.username
     , l.ctime
     , l.module
from bg_lock_info l
where bg_lock_id = &&v_lock_id
UNION
select '        <' action
     , l.bg_lock_id id
     , null
     , l.osuser
     , l.username
     , l.ctime
     , l.module
from bg_lock_info l
where blocking_bg_lock_id = &&v_lock_id
ORDER by 1 desc ,2
;

select object_id
      ,object_type
      ,DECODE(o.object_owner,NULL,NULL,o.object_owner || '.' || o.object_name) locked_object
      ,lock_mode
from bg_locked_object o
where bg_lock_id = &&v_lock_id
/

select object_id
      ,object_type
      ,DECODE(o.object_owner,NULL,NULL,o.object_owner || '.' || o.object_name) blocked_object
      ,lock_mode
from bg_locked_object o
where bg_lock_id IN
   (select bg_lock_id
    from  bg_lock_info
    where blocking_bg_lock_id = &&v_lock_id)
/


select sql_id
     , sql_text lsql
from   bg_lock_sql
where  sql_id = (select sql_id from bg_lock_info where bg_lock_id = &&v_lock_id)
order by sql_id,line;

select sql_id
     , sql_text bsql
from   bg_lock_sql
where  sql_id = (select sql_id from bg_lock_info where blocking_bg_lock_id = &&v_lock_id)
order by sql_id, line;



set feedback on;
