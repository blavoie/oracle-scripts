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

select space_partition_name
      ,ROUND(bg_space_monitor.partition_percent_full(space_partition_name)) pct_full
      ,ROUND(bg_space_monitor.partition_hours_until_full(space_partition_name)) hours_until_full
from   bg_space_partition_info
where  UPPER(space_partition_name) like '%ARCH%'
/
