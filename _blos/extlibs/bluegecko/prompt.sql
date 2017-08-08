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

REM ------------------------------------------------------------------------------------------------                                          
REM #DESC      : Set SQL prompt with user name, instance name
REM Usage      : Run automatically at SQL*Plus startup
REM Description: called by login.sql
REM ------------------------------------------------------------------------------------------------                                          
define xUser='X';
define xInstance='Y';
SET echo off TERMOUT OFF feed off
COLUMN user_name NEW_VALUE xUser NOPRINT
COLUMN instance_name NEW_VALUE xInstance NOPRINT
SELECT NVL(SUBSTR(host_name,1, INSTR(host_name,'.')-1),host_name) || ':' || user user_name, upper(instance_name) instance_name FROM v$instance;
'&_CONNECT_IDENTIFIER' user_sid from dual;
SET SQLPROMPT &xUser..&xInstance.>

set termout on
set feedback on 
set echo on
column user_name print
column instance_name print
