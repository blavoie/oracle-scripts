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

-- defines a variable vsid as a working sid to be used with the scripts sid-waits and sid-sql
-- also changes the sqlprompt to include the sid

define tsid=''''''
accept tsid char prompt 'Enter Session SID: '
set verify off


variable vsid number
variable vsqlp char(50)
column newprmt new_value newprmt1
set termout off
begin
:vsqlp := 'SQL> ';
end;
/

set termout on
declare
	dummy	char(1);
begin
	:vsid := to_number(&&tsid);
	
	select	'X'
	into	dummy
	from	v$session
	where	sid = :vsid;

      :vsqlp := '(watch sid '||to_char(:vsid)||')>';
exception
	WHEN NO_DATA_FOUND then
		raise_application_error(-20000,'Not a valid session ID');
end;
/

set termout off
select	rtrim(:vsqlp) newprmt from dual;

set sqlprompt '&&newprmt1';
set termout on
