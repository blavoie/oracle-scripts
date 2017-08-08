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

-- show objects consuming space in a given tablespace
-- also show how much space is left in the tablespace

accept ts prompt 'Enter tablespace name: '

column segment_name format a30
column MB format 999999

select tablespace_name, segment_name, sum(bytes)/1024/1024 MB
from dba_segments
where tablespace_name like UPPER('&&ts%')
group by tablespace_name,segment_name 
order by 1,3
/

select tablespace_name, sum(bytes)/1024/1024 
from dba_free_space 
where tablespace_name like upper('&&ts%')
group by tablespace_name
/
