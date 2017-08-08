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

-- show which snapshots are in which refresh groups

set pages 999
set lines 512
col job format 99999
select r.job, s.type, r.name as refresh_group, s.name as snapshot_name
  from dba_rgroup r, dba_snapshots s
 where r.refgroup = s.refresh_group
 order by r.job, s.name;
