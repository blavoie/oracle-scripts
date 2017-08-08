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

column USER_NAME format a20
column proxy_name format a20 wrap
column audit_option format a30 wrap

set line 120
ttitle CENTER 'Audited Privileges'
select * from dba_priv_audit_opts;

ttitle CENTER 'Audited Statements'
select * from dba_stmt_audit_opts;

ttitle CENTER 'Audited Objects'
select * from dba_obj_audit_opts;
