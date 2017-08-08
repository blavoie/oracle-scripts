SET ECHO ON TERM OFF SERVEROUT ON SIZE 1000000 NUMF "" SQLP SQL>;
WHENEVER SQLERROR CONTINUE;
SPO trcadictimp.log;
REM $Header: 224270.1 trcadictimp.sql 11.4.4.5 2012/11/21 carlos.sierra $
REM
REM Copyright (c) 2000-2013, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM
REM SCRIPT
REM   trcadictimp.sql
REM
REM DESCRIPTION
REM   This script imports a snapshot of the data dictionary into the
REM   Trace Analyzer repository. Then it allows the analysis of an
REM   EVENT 10046 Trace generated in a different system.
REM
REM PRE-REQUISITES
REM   1. Execute trcadictexp.sql in SOURCE, producing TRCA_DICT.zip.
REM   2. Unzip TRCA_DICT.zip into TARGET TRCA$STAGE directory.
REM      # cd <TRCA$STAGE directory>
REM      # unzip TRCA_DICT.zip
REM
REM PARAMETERS
REM   1. None.
REM
REM EXECUTION
REM   1. Start SQL*Plus connecting as a TRCA user
REM   2. Execute script trcadictimp.sql.
REM   3. Review logfile trcadictimp.log generated in current SQL*Plus
REM      local directory.
REM
REM EXAMPLES
REM   # sqlplus trcanlzr/trcanlzr
REM   SQL> start trca/dict/trcadictimp.sql
REM
REM NOTES
REM   1. In case of any errors in log, review files in TRCA$STAGE
REM      with names TRCA_*.log and TRCA_*.bad
REM   2. To determine current TRCA$STAGE directory path:
REM      SQL> SELECT directory_path
REM             FROM dba_directories
REM            WHERE directory_name = 'TRCA$STAGE';
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
EXEC trcadmin.trca$t.refresh_trca$_dict_from_that;
WHENEVER SQLERROR CONTINUE;
SPO OFF;
SET TERM ON;
PRO
PRO Trace Analyzer data dictionary repository has been imported.
PRO
PRO trcadictimp.sql completed.
