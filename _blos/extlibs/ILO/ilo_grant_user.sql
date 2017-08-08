REM ILO
REM Copyright (c) 2006 - 2008 by Method R Corporation. All rights reserved.
REM
REM This library is free software; you can redistribute it and/or
REM modify it under the terms of the GNU Lesser General Public
REM License as published by the Free Software Foundation; either
REM version 2.1 of the License, or (at your option) any later version.
REM
REM This library is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
REM Lesser General Public License for more details.
REM
REM You should have received a copy of the GNU Lesser General Public
REM License along with this library; if not, write to the Free Software
REM Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
REM
REM =========================================================================

set verify off termout on feedback on
set define '&'
set serveroutput on size 1000000
whenever sqlerror exit sql.sqlcode

PROMPT
PROMPT Granting necessary privileges to &&h_user schema owner
PROMPT

-- Basic privileges for connection and object creation
GRANT CREATE SESSION TO &&h_user;
GRANT CREATE TYPE TO &&h_user;
GRANT CREATE PROCEDURE TO &&h_user;
GRANT CREATE TRIGGER TO &&h_user;
GRANT CREATE TABLE TO &&h_user;
GRANT CREATE PUBLIC SYNONYM TO &&h_user;
GRANT CREATE SEQUENCE TO &&h_user;
GRANT CREATE SYNONYM TO &&h_user;
GRANT ALTER SESSION TO &&h_user;


-- The following grants are necessary for the ILO_SYSUTIL package.
-- Actual procedures and functions accessed within these system packages
-- are detailed prior to each grant. Some of these privileges may exist
-- already from PUBLIC. Revocation of these privileges will cause ILO failure.

declare
  procedure grant_exec (p_pkg varchar2) is
    v_sql varchar2(2000);
    no_package exception;
    PRAGMA EXCEPTION_INIT (no_package, -4042);
    ddl_timeout exception;
    PRAGMA EXCEPTION_INIT (ddl_timeout, -4021);
  begin
    for rec in 
    (select null from dual where not exists
      (select null from dba_tab_privs
         where owner = 'SYS'
           and table_name = p_pkg
           and privilege = 'EXECUTE'
           and grantee in ('PUBLIC','&&h_user',upper('&&h_user')) 
      )
    )
    loop
      begin
        v_sql := 'grant execute on sys.'||p_pkg||' to &&h_user';
        -- dbms_output.put_line(v_sql);
        execute immediate v_sql;
        dbms_output.put_line('Grant succeeded.');
      end;
    end loop;
  exception 
    when no_package then
      if p_pkg not in ('DBMS_MONITOR','DBMS_SUPPORT') then
        dbms_output.put_line('Package '||p_pkg||' does not exist.');
        raise;
      end if;
    when ddl_timeout then
      dbms_output.put_line('********************************************************************************');
      dbms_output.put_line('****************************     ERROR      ************************************');
      dbms_output.put_line('********************************************************************************');
      dbms_output.put_line('***                                                                          ***');
      dbms_output.put_line('*** Grant on '||p_pkg||' failed due to DDL lock timeout.');
      dbms_output.put_line('*** Another session/application has this package locked.');
      dbms_output.put_line('*** Retry installation at a time when the package is not in use.');
      dbms_output.put_line('*** Please consult MetaLink Doc ID 169139.1 for more information.');
      dbms_output.put_line('***                                                                          ***');
      dbms_output.put_line('********************************************************************************');
      raise;
    when others then raise;
  end grant_exec;
begin
  -- DBMS_SYSTEM.KSDDDT  -- writes a datestamp to trace file
  -- DBMS_SYSTEM.KSDWRT  -- writes text to trace file or alert log
  grant_exec('DBMS_SYSTEM');

  -- DBMS_MONITOR.SESSION_TRACE_ENABLE  -- for version 10+
  -- DBMS_MONITOR.SESSION_TRACE_DISABLE
  -- DBMS_SUPPORT.START_TRACE           -- for versions 7-9
  -- DBMS_SUPPORT.STOP_TRACE
  grant_exec('DBMS_MONITOR');
  grant_exec('DBMS_SUPPORT');

  -- DBMS_SESSION.SET_IDENTIFIER  -- to set CLIENT_IDENTIFIER
  grant_exec('DBMS_SESSION');

  -- DBMS_ALERT.REGISTER
  -- DBMS_ALERT.WAITANY
  -- DBMS_ALERT.WAITONE
  -- DBMS_ALERT.SIGNAL
  -- DBMS_ALERT.REMOVE
  -- DBMS_ALERT.REMOVEALL
  grant_exec('DBMS_ALERT');

  -- DBMS_UTILITY.DB_VERSION  -- returns database version
  grant_exec('DBMS_UTILITY');
end;
/

-- To retrieve session information like program, os_user, and session type
GRANT SELECT ON SYS.V_$SESSION TO &&h_user;

-- To retrieve SPID for current process
GRANT SELECT ON SYS.V_$PROCESS TO &&h_user;

-- To retrieve instance name for database
GRANT SELECT ON SYS.V_$INSTANCE TO &&h_user;
