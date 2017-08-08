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

@bigdates

SELECT f.tablespace_name, max(b.checkpoint_time) last_backup_time
  FROM   dba_data_files f
        ,v$backup_datafile b
        ,dba_tablespaces t
  WHERE b.file# = f.file_id
  AND   f.tablespace_name = t.tablespace_name
  AND   t.status = 'ONLINE'
  AND   t.contents != 'TEMPORARY'
  GROUP BY f.tablespace_name;
