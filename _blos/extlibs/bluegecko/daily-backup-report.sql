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

set pages 500
TTITLE "Blue Gecko Backup Report"

column backup_type heading 'Backup Type'
column recoverable_to heading 'Recoverable To'

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI';
select 'Datafile Backup'  backup_type
       ,max_checkpoint_time recoverable_to
from v$backup_datafile_summary
UNION
select 'Archivelog Backup' backup_type
       ,max_next_time recoverable_to
from v$backup_archivelog_summary
UNION
select 'Controlfile Backup' backup_type
       ,max_checkpoint_time recoverable_to
from v$backup_controlfile_summary
/


set pages 500
TTITLE "Tablespace Backup Report"
Column last_backup_time FORMAT a25 heading "Last Successful Backup"
column tablespace_name  heading "Tablespace"

SELECT tablespace_name, TO_CHAR(MIN(last_backup_time),'DD-MON-YYYY HH24:MI:SS') last_backup_time FROM 
(SELECT f.tablespace_name tablespace_name, max(b.checkpoint_time) last_backup_time
  FROM   dba_data_files f
        ,v$backup_datafile b
        ,dba_tablespaces t
  WHERE b.file# = f.file_id
  AND   f.tablespace_name = t.tablespace_name
  AND   t.status = 'ONLINE'
  AND   t.contents != 'TEMPORARY'
  GROUP BY f.tablespace_name)
GROUP BY tablespace_name
order by tablespace_name
/

