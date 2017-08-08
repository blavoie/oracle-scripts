set termout off
set feedback off
set verify off
set echo off

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
REM Author     : emurray
REM #DESC      : Set default sqlplus environment
REM Usage      : run automatically at sqlplus logon
REM Description: called by login.sql
REM ------------------------------------------------------------------------------------------------

set autocommit off
set echo off 
set feed on
set head on
set lines 200
set long 10000
set pages 1000 
set serveroutput on size 1000000
set trimspool on 
set verify off
set pause off
ttitle off
clear breaks
clear columns

col blksz	new_value blocksz

set termout off
select value blksz
  from v$parameter
  where name = 'db_block_size' 
;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
set termout on
set feedback on 
set verify on
set echo on 
