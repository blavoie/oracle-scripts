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

-- show long running operations for a given osuser
@plusenv
accept ouser prompt 'Please enter osuser: '

select sid, qcsid, time_remaining, message
from v$session_longops
where sid in (
  select sid from v$session
  where osuser = '&ouser')
and time_remaining !=0
order by sid;
