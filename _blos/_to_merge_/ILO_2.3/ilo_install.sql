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
PROMPT Objects Installed:
PROMPT
PROMPT * Package ILO_SYSUTIL 
PROMPT * Package ILO_UTIL 
PROMPT * Package ILO_TASK
PROMPT * Package ILO_TIMER
PROMPT
PROMPT * Public Synonym ILO_SYSUTIL 
PROMPT * Public Synonym ILO_UTIL 
PROMPT * Public Synonym ILO_TASK
PROMPT * Public Synonym ILO_TIMER
PROMPT
PROMPT * Execute privileges are granted to PUBLIC for all packages except ILO_SYSUTIL
PROMPT
PROMPT For more information, consult the readme.txt file.
PROMPT
PROMPT ========================================================================
PROMPT 
PROMPT Preparing to start. Hit enter to continue...
PAUSE
PROMPT

set define '&' 
set echo off heading off termout off feedback off verify off

select 'start ' || decode(user, 'SYS', 'ilo_sysok.sql', 'ilo_sysnotok.sql')
from  dual

spool ilo_install.tmp
/
spool off
start ilo_install.tmp

ACCEPT h_user char default ILO prompt '*** Enter the user you wish to own ILO [ilo]: '
ACCEPT h_pw   char             prompt '*** Enter the password for this user: ' HIDE
ACCEPT alias  char             prompt '*** Enter the TNS alias for this user: '

VARIABLE tnsalias varchar2(2000);
begin
  if '&&alias' is null then
    :tnsalias := '"'; -- split the double quotes here and at the connect to avoid a null tnsalias which will prompt user
  elsif '&&alias' like '@%' then
    :tnsalias := '"&&alias';
  else
    :tnsalias := '"@&&alias';
  end if;
end;
/

set echo off heading off termout off feedback off
rem create the tnsalias subst variable for usage in connect later on
column tempalias new_value tnsalias
select :tnsalias tempalias from dual;

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


select 'start ' || 'ilo_userok.sql &&h_user'
from all_users where upper(username) = upper('&&h_user')
UNION
select 'start ' || 'ilo_usernotok.sql &&h_user'
from dual 
where not exists (select null from all_users where upper(username) = upper('&&h_user'))

spool ilo_install.tmp
/
spool off
start ilo_install.tmp

start ilo_install_user.sql

REM The following statement requires this script to be run with DBA privilege.

set echo off heading off termout off feedback off
spool ilo_install.tmp
   SELECT 'PROMPT ... Installing DBMS_SUPPORT' || chr(13) || chr(10)
          || '@?' || f.sep || 'rdbms' || f.sep || 'admin' || f.sep || 'dbmssupp.sql'
   FROM Product_Component_Version v,
        (SELECT DECODE( TO_CHAR( INSTR( DBMS_UTILITY.PORT_STRING, '/WIN_', 1 ) ),
                        '0', '/',  -- Not Windows, so use UNIX separator
                        '\' ) sep
         FROM Dual) f
   WHERE SUBSTR( v.Version, 1, INSTR( Version, '.', 1 )-1 ) = '9'
     AND v.Product LIKE 'Oracle%'
     AND NOT EXISTS
        (SELECT 1
         FROM DBA_Objects o
         WHERE o.Object_Name = 'DBMS_SUPPORT'
           AND o.Object_Type = 'PACKAGE')
UNION ALL
   SELECT 'PROMPT ... Installing DBMS_MONITOR' || chr(13) || chr(10)
          || '@?' || f.sep || 'rdbms' || f.sep || 'admin' || f.sep || 'catmntr.sql'
   FROM Product_Component_Version v,
        (SELECT DECODE( TO_CHAR( INSTR( DBMS_UTILITY.PORT_STRING, '/WIN_', 1 ) ),
                        '0', '/',  -- Not Windows, so use UNIX separator
                        '\' ) sep
         FROM Dual) f
   WHERE SUBSTR( v.Version, 1, INSTR( Version, '.', 1 )-1 ) = '10'
     AND v.Product LIKE 'Oracle%'
     AND NOT EXISTS
        (SELECT 1
         FROM DBA_Objects o
         WHERE o.Object_Name = 'DBMS_MONITOR'
           AND o.Object_Type = 'PACKAGE');
spool off

set termout on
spool ilo_install.log

@ilo_install.tmp
PROMPT
set serveroutput on size 1000000
declare
  procedure create_public_synonym (p_synonym varchar2, p_obj varchar2 default null) is
    already_exists exception;
    PRAGMA EXCEPTION_INIT (already_exists, -955);
    v_owner dba_synonyms.table_owner%type;
  begin
    dbms_output.put_line('... Creating public synonym '||p_synonym||' for &&h_user..'||nvl(p_obj,p_synonym));
    execute immediate 'create public synonym '||p_synonym||' for &&h_user..'||nvl(p_obj,p_synonym);
  exception
    when already_exists then
      begin
        select table_owner into v_owner from dba_synonyms
          where owner = 'PUBLIC' and synonym_name = upper(p_synonym);
        if upper(v_owner) != upper('&&h_user') then
          dbms_output.put_line('********************************************************************************');
          dbms_output.put_line('****************************     WARNING      **********************************');
          dbms_output.put_line('********************************************************************************');
          dbms_output.put_line('***                                                                          ***');
          dbms_output.put_line('*** Public synonym '||p_synonym||' already exists for schema: '||v_owner);
          dbms_output.put_line('*** Modify the public synonyms manually if desired.');
          dbms_output.put_line('***                                                                          ***');
          dbms_output.put_line('********************************************************************************');
        end if;
      end;
  end create_public_synonym;
  procedure drop_public_synonym (p_obj varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -1432);
  begin
    dbms_output.put_line('... Dropping public synonym '||p_obj);
    execute immediate 'drop public synonym '||p_obj;
  exception
    when not_exists then null;
    when others then dbms_output.put_line(sqlerrm);
  end drop_public_synonym;
  procedure create_synonym (p_synonym varchar2, p_obj varchar2) is
    already_exists exception;
    PRAGMA EXCEPTION_INIT (already_exists, -955);
  begin
    dbms_output.put_line('... Creating synonym '||p_synonym||' for &&h_user..'||p_obj);
    execute immediate 'create synonym &&h_user..'||p_synonym||' for &&h_user..'||p_obj;
  exception
    when already_exists then
          dbms_output.put_line('********************************************************************************');
          dbms_output.put_line('****************************     WARNING      **********************************');
          dbms_output.put_line('********************************************************************************');
          dbms_output.put_line('***                                                                          ***');
          dbms_output.put_line('*** Synonym '||p_synonym||' already exists for this schema.');
          dbms_output.put_line('*** Modify the private synonyms manually if desired.');
          dbms_output.put_line('***                                                                          ***');
          dbms_output.put_line('********************************************************************************');
  end create_synonym;
  procedure drop_package (p_obj varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -4043);
  begin
    dbms_output.put_line('... Dropping package &&h_user..'||p_obj);
    execute immediate 'drop package &&h_user..'||p_obj;
  exception
    when not_exists then null;
    when others then dbms_output.put_line(sqlerrm);
  end drop_package;
begin
  create_public_synonym('ilo_task');
  create_public_synonym('ilo_timer');
  create_public_synonym('ilo_util');
  create_public_synonym('ilo_sysutil');
  -- If upgrading from 2.0 or earlier, replace existing synonyms to handle the new naming convention.
  for rec in (select null from dba_synonyms
               where table_owner in ('&&h_user',upper('&&h_user'))
                 and owner = 'PUBLIC' and synonym_name = 'HOTSOS_ILO_TASK'
                 and rownum = 1
             )
  loop
    drop_public_synonym('hotsos_ilo_task');
    drop_public_synonym('hotsos_ilo_timer');
    drop_public_synonym('hotsos_sysutil');
    drop_package('hotsos_ilo_task');
    drop_package('hotsos_ilo_timer');
    drop_package('hotsos_sysutil');
    create_public_synonym('hotsos_ilo_task','ilo_task');
    create_public_synonym('hotsos_ilo_timer','ilo_timer');
    create_public_synonym('hotsos_sysutil','ilo_sysutil');
    -- create private synonyms in case the public synonyms were not being used and
    -- references were made like hotsos.hotsos_ilo_task.begin_task
    create_synonym('hotsos_ilo_task','ilo_task');
    create_synonym('hotsos_ilo_timer','ilo_timer');
    create_synonym('hotsos_sysutil','ilo_sysutil');
  end loop;
end;
/

-- For upgrades from 1.5 to 1.6, remove the obsolete SYS.HOTSOS_SYSUTIL
-- If a new install, leave it alone so they can coexist
declare
  procedure drop_package (p_package varchar2) is
    not_exists exception;
    PRAGMA EXCEPTION_INIT (not_exists, -4043);
  begin
    execute immediate 'drop package '||p_package;
    dbms_output.put_line('... Dropping obsolete package '||p_package);
  exception
    when not_exists then null;
  end drop_package;
begin
  for rec in (select object_name from all_objects where owner = '&&h_user' and object_name = 'HOTSOS_ILO_TASK' and object_type = 'PACKAGE')
  loop
    execute immediate 'select 1 from dual where &&h_user..hotsos_ilo_task.get_version < 1.6';
    if sql%rowcount > 0 then
      drop_package('SYS.HOTSOS_SYSUTIL');
    end if;
  end loop;
exception when others then null;
end;
/

PROMPT ... Granting EXECUTE privs on SYS.DBMS_MONITOR or SYS.DBMS_SUPPORT to &&h_user   
declare
  no_package exception;
  PRAGMA EXCEPTION_INIT (no_package, -4042);
begin
  begin
    execute immediate 'GRANT EXECUTE ON  SYS.DBMS_MONITOR TO &&h_user';
  exception when no_package then null;
  end;
  begin
    execute immediate 'GRANT EXECUTE ON  SYS.DBMS_SUPPORT TO &&h_user';
  exception when no_package then null;
  end;
end;
/

PROMPT =========================================================================
PROMPT 
PROMPT ... Connecting as &&h_user
connect &&h_user/"&&h_pw&&tnsalias 
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
