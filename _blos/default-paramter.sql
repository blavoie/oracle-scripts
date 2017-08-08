-- http://www.oraclethoughts.com/sqlplus_/sqlplus-default-values-for-script-parameters/

SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1
SELECT '' "1" FROM DUAL WHERE ROWNUM = 0;
REM Just to use more meaningfull variable, i will give it a name
 
DEF WORK_SCHEMA_NAME='&1'
 
BEGIN
  IF '&&WORK_SCHEMA_NAME' IS NOT NULL THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA=&&WORK_SCHEMA_NAME';
  END IF;
END;
/
 
SELECT 'Now i''m working on schema: '
       || SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
       || ' as user: '|| USER
  FROM DUAL;
 
PROMPT I can do my processing here