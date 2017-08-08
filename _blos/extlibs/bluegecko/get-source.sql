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

@plusenv

accept v_owner prompt 'Please enter owner of package or procedure: '
accept v_pname prompt 'Please enter name of package or procedure: '
accept v_type  prompt 'Please enter type of source, (PACKAGE,PROCEDURE,FUNCTION,TRIGGER,TYPE): '

set heading off;

select text
from   dba_source
where  owner = UPPER('&&v_owner')
and    name  = UPPER('&&v_pname')
and   ( TYPE  = UPPER('&&v_type')
   OR   (UPPER('&&v_type') = 'PACKAGE' AND TYPE IN ('PACKAGE','PACKAGE BODY')))
order by TYPE, LINE
/

