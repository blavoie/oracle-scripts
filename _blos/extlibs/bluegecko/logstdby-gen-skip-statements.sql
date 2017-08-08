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

set lines 250
set trimspool on
set pages 1000
set heading 
select 'exec dbms_logstdby.skip(STMT=>''' || statement_opt 
        || ''',SCHEMA_NAME=>'''  || owner  
        || ''',OBJECT_NAME =>''' || name 
        || ''',PROC_NAME=>''' || proc 
        || ''',USE_LIKE=>''' || DECODE(use_like,'N','TRUE','FALSE')
        || ');'  skip_statement
from dba_logstdby_skip
where error='N'
UNION
select 'exec dbms_logstdby.skip_error(STMT=>''' || statement_opt 
        || ''',SCHEMA_NAME=>'''  || owner  
        || ''',OBJECT_NAME =>''' || name 
        || ''',PROC_NAME=>''' || proc 
        || ''',USE_LIKE=>''' || DECODE(use_like,'N','TRUE','FALSE')
        || ');' skip_statment
from dba_logstdby_skip
where error='Y'
ORDER BY 1
/
