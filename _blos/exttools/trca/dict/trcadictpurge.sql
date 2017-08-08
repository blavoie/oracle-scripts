SET ECHO ON TERM OFF SERVEROUT ON SIZE 1000000 NUMF "" SQLP SQL>;
WHENEVER SQLERROR CONTINUE;
SPO trcadictpurge.log;
REM $Header: 224270.1 trcadictpurge.sql 11.4.4.5 2012/11/21 carlos.sierra $
REM
REM Copyright (c) 2000-2013, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM
REM SCRIPT
REM   trcadictpurge.sql
REM
REM DESCRIPTION
REM   This script erases the Trace Analyzer data dictionary
REM   repository. If none is imported afterwards, then the Trace
REM   Analyzer will reload a fresh copy of the local dictionary.
REM
REM PRE-REQUISITES
REM   1. None.
REM
REM PARAMETERS
REM   1. None.
REM
REM EXECUTION
REM   1. Start SQL*Plus connecting as any TRCA user
REM   2. Execute script trcadictpurge.sql.
REM   3. Review logfile trcadictpurge.log generated in current SQL*Plus
REM      local directory.
REM
REM EXAMPLES
REM   # sqlplus trcanlzr/trcanlzr
REM   SQL> start trca/dict/trcadictpurge.sql
REM
REM NOTES
REM   1. None.
REM
-- begin common
DEF _SQLPLUS_RELEASE
SELECT USER FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') current_time FROM DUAL;
SELECT * FROM v$version;
SELECT * FROM v$instance;
SELECT name, value FROM v$parameter2 WHERE name LIKE '%dump_dest';
SELECT directory_name||' '||directory_path directories FROM dba_directories WHERE directory_name LIKE 'SQLT$%' OR directory_name LIKE 'TRCA$%' ORDER BY 1;
-- end common
SET ECHO OFF;
SET TERM OFF HEA ON LIN 2000 PAGES 1000 TRIMS ON TIM OFF;
COL connected_user FOR A30;
SELECT user connected_user FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') current_time FROM DUAL;
SELECT * FROM v$version;
COL library FOR A64 HEA 'Libraries';
SELECT object_type||' '||object_name||' ('||status||')' library
  FROM dba_objects
 WHERE owner = 'TRCANLZR'
   AND object_type IN ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION')
 ORDER BY
       object_type, object_name;
WHENEVER SQLERROR EXIT SQL.SQLCODE;
EXEC trcadmin.trca$p.set_nls;
EXEC trcadmin.trca$g.general_initialization;
COL tool_version FOR A16 HEA 'Tool Version';
SELECT trcadmin.trca$g.get_param('tool_version', 'I') tool_version FROM DUAL;
COL install_date FOR A16 HEA 'Install Date';
SELECT trcadmin.trca$g.get_param('install_date', 'I') install_date FROM DUAL;
COL host_name FOR A128 HEA 'Host Name';
SELECT trcadmin.trca$g.get_param('tool_host_name', 'I') host_name FROM DUAL;
COL column_value FOR A128 HEA 'Directories';
SELECT column_value FROM TABLE(trcadmin.trca$g.directories);
COL column_value FOR A128 HEA 'Libraries';
SELECT column_value FROM TABLE(trcadmin.trca$g.packages);
EXEC trcadmin.trca$t.purge_trca$_dict;
WHENEVER SQLERROR CONTINUE;
SPO OFF;
SET TERM ON;
PRO
PRO Trace Analyzer data dictionary repository has been purged.
PRO
PRO trcadictpurge.sql completed.
