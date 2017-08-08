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

-- generate statements to turn parallelism off for indexes owned by a particular schema

undefine the_schema
accept the_schema prompt 'Generate statements for which schema?: '

select 'exec ddl_util.hot_ddl(''alter index &&the_schema.' || index_name || ' noparallel'');'
from dba_indexes where owner = UPPER('&&the_schema')
and degree > 1
/
