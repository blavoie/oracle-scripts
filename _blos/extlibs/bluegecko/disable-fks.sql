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

-- Generates statements to disable foreign key references to a table. Use this with the                                                                                                                        
-- script enable-fks to make performing maintenance on tables easier.                                                                                                                                          

@plusenv
set verify off
set trimspool on


ACCEPT tn prompt 'Please enter table name or fragment: '
ACCEPT own prompt 'Please enter table owner: '

Select table_name
from   dba_tables
where  table_name like UPPER('&&tn')
and    owner = UPPER('&&own');


select 'alter table &&own'|| '.' || table_name || ' disable constraint '
     || constraint_name || ';' stmt
from dba_constraints
where constraint_type = 'R'
and status = 'ENABLED'
and r_constraint_name =
(select constraint_name
 from   dba_constraints
 where  table_name LIKE UPPER('&&tn')
 and owner = UPPER('&&own')
 and    constraint_type = 'P')
/

