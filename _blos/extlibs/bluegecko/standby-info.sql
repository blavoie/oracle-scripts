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

--  Standby information

@plusenv


column dest_name format a30
column destination format a40
column status format a15


SELECT ad.dest_id
      ,ad.inst_id
      ,ad.destination
      ,ad.dest_name
      ,al.standby_last_log_applied
      ,ad.log_sequence
      ,ad.status
FROM gv$archive_dest ad
    ,(SELECT MAX(completion_time) standby_last_log_applied
            ,dest_id
            ,inst_id
      FROM  gv$archived_log
      WHERE applied = 'YES'
      AND   standby_dest = 'YES'
      GROUP BY dest_id, inst_id) al
WHERE al.inst_id = ad.inst_id
AND   al.dest_id = ad.dest_id
AND   db_unique_name != 'NONE'
order by dest_id, inst_id
/

