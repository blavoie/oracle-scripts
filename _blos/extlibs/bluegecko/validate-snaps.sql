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

-- shows information about snapshots
set feedback off;
@plusenv

col master_link format a15
col name format a30
col owner format a8
select r.owner, r.name, count(*), s.master_link
  from dba_rgroup r, dba_snapshots s
 where r.refgroup (+) = s.refresh_group
 group by r.owner, r.name, s.master_link;

set heading off
select '*** empty refresh groups ***' from dual;
set heading on;

select r.owner, r.name
  from dba_rgroup r
 where r.refgroup not in
       (select s.refresh_group
          from dba_snapshots s);


set heading off;
select '*** orphaned snaps - snaps with no refresh group ***' from dual;
set heading on;

select s.owner, s.name
  from dba_snapshots s
 where s.refresh_group not in
       (select r.refgroup from dba_rgroup r) 
       or s.refresh_group is null;

set feedback on;
