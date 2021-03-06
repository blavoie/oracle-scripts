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

undefine v_hot_operation;

accept v_hot_operation prompt 'Please enter the sql statement to run: ';

declare
  resource_busy exception;
  pragma exception_init (resource_busy,-54);
BEGIN

loop
   begin
     execute immediate RTRIM('&&v_hot_operation',';');
     exit;
   exception
    when resource_busy then
     dbms_lock.sleep(1);
   end;
end loop;
end;
/
