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

--  show all indexes for a given tale

set linesize 132
set verify off

column column_name format a29
column index_owner format a15


ACCEPT tn prompt 'Please enter table name or fragment: '
ACCEPT usr prompt 'Please enter table owner or fragment: '

select table_name
from dba_tables 
where table_name like UPPER('&tn%');

select index_owner,index_name,column_position,column_name
FROM all_ind_columns
where table_name like UPPER('&tn%')
and   table_owner like UPPER('&usr%')
order by index_name,column_position;
