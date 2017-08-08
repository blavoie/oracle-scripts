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

set pages 0
spo /tmp/tmpsql.sql

select 'alter '||object_type||' '||owner||'.'||object_name||' compile;' from
dba_objects where status = 'INVALID'
and object_type != 'PACKAGE BODY'
/

select 'alter package '||owner||'.'||object_name||' compile body;' from
dba_objects where status = 'INVALID'
and object_type = 'PACKAGE BODY'
/
spo off
pause hit return to continue
@/tmp/tmpsql
