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

set heading off
set verify off
ttitle off
column v_database NEW_VALUE v_database NOPRINT;
column v_dt NEW_VALUE v_dt NOPRINT;

column db_unique_name NOPRINT;
select db_unique_name v_database
      ,TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS') v_dt
from v$database;

set lines 100
set pages 50000
set heading on
set feedback off
set trimspool on 

column backup_type heading 'Backup Type'
column recoverable_to heading 'Recoverable To'

TTITLE LEFT v_database ':  Overall Backup Report  -  ' v_dt SKIP 2

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

Column last_backup_time FORMAT a25 heading "Last Successful Backup"
column tablespace_name  heading "Tablespace"
TTITLE OFF

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
