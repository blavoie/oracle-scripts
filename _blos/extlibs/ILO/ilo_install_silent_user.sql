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
PROMPT ========================================================================
PROMPT
PROMPT This script will install the Instrumentation Library for Oracle (ILO)
PROMPT and its associated utilities.
PROMPT
PROMPT This script executes without prompt, for silent installs. No arguments are
PROMPT expected or used. The script should be executed while connected to the schema
PROMPT which will own the ILO objects. The ilo_install_silent_sys.sql script must be
PROMPT executed prior to this one for appropriate permissions to be granted.
PROMPT
PROMPT Objects Installed:
PROMPT
PROMPT * Package ILO_SYSUTIL 
PROMPT * Package ILO_UTIL 
PROMPT * Package ILO_TASK
PROMPT * Package ILO_TIMER
PROMPT
PROMPT For more information, consult the readme.txt file.
PROMPT
PROMPT ========================================================================
PROMPT 
PROMPT

set define '&' 
set echo off heading off termout off feedback off verify off

rem set the version variable for use in packages, must be NUMBER datatype, x.y
column iloversion new_value ilo_version
select '2.3' iloversion from dual;

rem get the database version for use in ILO_SYSUTIL package
VARIABLE g_db_major_ver varchar2(64);
VARIABLE g_db_prod varchar2(64);
VARIABLE g_db_ver varchar2(64);

DECLARE
   v_db_ver            VARCHAR2(64);
   v_compat_ver        VARCHAR2(64);
   v_db_major          VARCHAR2(5);
   v_db_minor          VARCHAR2(5);
   v_db_ver_minusmajor VARCHAR2(10);
   v_idx               PLS_INTEGER;
   v_del               VARCHAR2(2) := '.';
BEGIN
   DBMS_UTILITY.DB_VERSION(v_db_ver, v_compat_ver);
   v_idx               := INSTR(v_db_ver, v_del);
   v_db_major          := SUBSTR(v_db_ver, 1, v_idx - 1);
   v_db_ver_minusmajor := SUBSTR(v_db_ver, v_idx + 1, LENGTH(v_db_ver));
   v_idx               := INSTR(v_db_ver_minusmajor, v_del);
   v_db_minor          := SUBSTR(v_db_ver_minusmajor, 1, v_idx - 1);
   -- Setting the major number
   :g_db_major_ver := v_db_major;
   -- Setting the major and minor number as a product number
   :g_db_prod := v_db_major || '.' || v_db_minor;
   -- Setting the entire db verion
   :g_db_ver := v_db_ver;
END;
/

column a_db_ver new_value g_db_ver
column a_db_prod new_value g_db_prod
column a_db_major_ver new_value g_db_major_ver
select :g_db_major_ver a_db_major_ver,:g_db_prod a_db_prod,:g_db_ver a_db_ver from dual;

set termout on
set serveroutput on size 1000000

PROMPT =========================================================================
PROMPT 
PROMPT ... Installing ILO_UTIL Package Spec
@ilo_util.pks
/
show errors;
PROMPT ... Installing ILO_UTIL Package Body
@ilo_util.pkb
/
show errors;
PROMPT ... Installing ILO_SYSUTIL Package Spec
@ilo_sysutil.pks
/
show errors;
PROMPT ... Installing ILO_SYSUTIL Package Body
@ilo_sysutil.pkb
/
show errors;
PROMPT ... Installing ILO_TASK Package Spec
@ilo_task.pks
/
show errors;
PROMPT ... Installing ILO_TIMER Package Spec
@ilo_timer.pks
/
show errors;
PROMPT ... Installing ILO_TIMER Package Body
@ilo_timer.pkb
/
show errors;
PROMPT ... Installing ILO_TASK Package Body
@ilo_task.pkb
/
show errors;
PROMPT ... Granting EXECUTE privs on packages to PUBLIC
grant execute on ILO_TASK to PUBLIC;
grant execute on ILO_TIMER to PUBLIC;
grant execute on ILO_UTIL to PUBLIC;
PROMPT
PROMPT =========================================================================
PROMPT Installation of ILO complete.
PROMPT =========================================================================
spool off
exit
