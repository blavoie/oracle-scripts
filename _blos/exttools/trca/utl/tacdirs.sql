SET ECHO ON TERM OFF;
SPOOL tacdirs.log;
REM $Header: 224270.1 tacdirs.sql 11.4.5.0 2012/11/21 carlos.sierra $
REM
REM Copyright (c) 2000-2013, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM
REM SCRIPT
REM   tacdirs.sql
REM
REM DESCRIPTION
REM   This script creates a pointer to the server directory used by
REM   TRCANLZR to import TRCA repositories.
REM
REM PRE-REQUISITES
REM   1. This script must be executed connected INTERNAL (SYS) as
REM      SYSDBA
REM   2. ORACLE must have read/write access to specified directory
REM
REM PARAMETERS
REM   1. Full path of existing "stage" directory (required)
REM      This value is case sensitive, and actual directory must
REM      exists in server prior to the execution of this script.
REM      Path should not end with / or \.
REM
REM EXECUTION
REM   1. Navigate to trca/utl directory
REM   2. Start SQL*Plus connecting INTERNAL (SYS) as SYSDBA
REM   3. Execute script tacdirs.sql
REM
REM EXAMPLE
REM   # cd trca/utl
REM   # sqlplus /nolog
REM   SQL> connect / as sysdba
REM   SQL> start tacdirs.sql [full output directory path]
REM   SQL> start tacdirs.sql /home/johannes/csierra/traces
REM
REM NOTES
REM   1. For possible errors see tacdirs.log file
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
WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET TERM ON;
BEGIN
  IF USER <> 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20100, 'Directory alias should be created connected as SYS, not as '||USER);
  END IF;
END;
/

/* ---------------------------------------------------------------------- */

PRO ... Creating TRCA$ output Directory

DEF directory_path = '&1';

BEGIN
  IF '&&directory_path.' LIKE '%?%' OR '&&directory_path.' LIKE '%*%' THEN
    RAISE_APPLICATION_ERROR(-20101, 'Directory &&directory_path cannot contain "?" or "*" symbols');
  END IF;
  IF SUBSTR('&&directory_path.', LENGTH('&&directory_path.'), 1) IN (' ', '/', '\') THEN
    RAISE_APPLICATION_ERROR(-20102, 'Directory &&directory_path. cannot end with " ", "/" or "\" symbols');
  END IF;
END;
/

CREATE OR REPLACE DIRECTORY TRCA$STAGE AS '&&directory_path.';

GRANT READ,WRITE ON DIRECTORY TRCA$STAGE TO trcadmin;

WHENEVER SQLERROR CONTINUE;
EXEC trcadmin.trca$g.general_initialization(TRUE);

SPOOL OFF;
UNDEFINE 1 directory_path
PRO TACDIRS completed.
