SET ECHO ON TERM OFF LIN 2000 PAGES 100 HEA ON TRIMS ON SERVEROUT ON SIZE 1000000 NUMF "" TIM OFF SQLP SQL>;
SPO trcapurge.log;
REM $Header: 224270.1 trcapurge.sql 11.4.5.0 2012/11/21 carlos.sierra $
REM
REM Copyright (c) 2000-2013, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM
REM SCRIPT
REM   trcapurge.sql
REM
REM DESCRIPTION
REM   This script is used to purge data out of large staging tables
REM   if these large objects were created as PERMANENT tables instead
REM   of GLOBAL TEMPORARY.
REM
REM PRE-REQUISITES
REM   1. Install Trace Anallyzer tool as per instructions.txt
REM      provided.
REM   2. Large staging tables were created as PERMANENT.
REM
REM PARAMETERS
REM   1. Tool execution ID (required). A list of candidate IDs is
REM      presented to the user executing this script.
REM
REM EXECUTION
REM   1. Navigate to trca/run directory
REM   2. Start SQL*Plus connecting as TRCANLZR or any TRCA user
REM   3. Execute script trcapurge.sql passing tool_execution_id
REM      (parameter can be passed inline or until requested)
REM
REM EXAMPLE
REM   # cd trca/run
REM   # sqlplus trcanlzr
REM   SQL> start trcapurge.sql [tool_execution_id];
REM   SQL> start trcapurge.sql 83975;
REM   SQL> start trcapurge.sql;
REM
REM NOTES
REM   1. For possible errors see trcapurge.log
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
SET ECHO OFF TERM OFF HEA ON LIN 2000 PAGES 1000 TRIMS ON TIM OFF;
SET TERM ON;
SELECT id tool_execution_id,
       TO_CHAR(parse_start, 'DD-MON-YY HH24:MI') parse_date,
       SUBSTR(file_name, 1, 80) trace_filename
  FROM trcadmin.trca$_purge_candidate_v
 ORDER BY
       id;
PRO
PRO Parameter 1: TOOL_EXECUTION_ID to purge (required)
PRO
DEF tool_execution_id = '&1';
PRO
PRO ...purging data from staging tables for TOOL_EXECUTION_ID &&tool_execution_id.
PRO
EXEC trcadmin.trca$p.purge_tool_execution_id(p_tool_execution_id => '&&tool_execution_id.');
PRO
SPOOL OFF;
PRO NOTE:
PRO   trcapurge complete. Please check trcapurge.log for any errors.
PRO
CL COL
UNDEFINE 1 TOOL_EXECUTION_ID
PRO TRCAPURGE completed.
