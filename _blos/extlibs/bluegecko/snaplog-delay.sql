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

--  Shows the delay in snapshot refreshes on the source and the target that should be refreshing

col name format a30
col snapshot_site format a14
col id format 9999
col min_ago format 9999.99
undefine minutes_behind
prompt ******
prompt NOTE: this script may give spurrious rows, since the 
prompt snapshot_id's are generated on the SNAPSHOT site, and 
prompt we shouldn't really be joining the DBA_REGISTERED_SNAPSHOTS 
prompt and DBA_SNAPSHOT_LOGS tables via the SNAPSHOT_ID column.
prompt If you see two rows with the same snapshot_id and time, it's
prompt most likely you're seeing the effect of this incorrect join
prompt and only one row is "correct".  Another way to do this is
prompt to OUTER JOIN based on the names, but sometimes we don't
prompt name the snapshot the same as the master table. 
prompt ******
select drs.name, drs.snapshot_site, 
       dsl.snapshot_id as id, dsl.current_snapshots,
       (sysdate - dsl.current_snapshots)*(24*60) as min_ago
   from dba_registered_snapshots drs, dba_snapshot_logs dsl
  where drs.snapshot_id (+) = dsl.snapshot_id
--    and drs.name (+) = dsl.master
    and dsl.current_snapshots < sysdate - (&&minutes_behind / (24*60)) ;
