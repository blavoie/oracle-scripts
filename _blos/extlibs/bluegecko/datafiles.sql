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

-- Show all datafiles and sizes for a given tablespace

@plusenv

accept tbsp prompt 'For tablespace (optional): '
column file_name format a60

select file_name  file_name
      ,tablespace_name
      ,bytes/(1024*1024) M
from dba_data_files
where tablespace_name = upper('&tbsp')
or    '&tbsp' is null
order by tablespace_name, file_name
/
