REM $Header: 215187.1 sqltcommon3.sql 11.4.5.0 2012/11/21 carlos.sierra $
-- begin common
PRO
PRO Paremeter 2:
PRO ^^tool_repository_schema. password (required)
PRO
DEF enter_tool_password = '^2';
WHENEVER SQLERROR EXIT SQL.SQLCODE;
BEGIN
  IF '^^enter_tool_password.' IS NULL THEN
    RAISE_APPLICATION_ERROR(-20104, 'No password specified for user ^^tool_repository_schema.');
  END IF;
  IF '^^enter_tool_password.' LIKE '% %' THEN
    RAISE_APPLICATION_ERROR(-20105, 'Password for user ^^tool_repository_schema. cannot contain spaces');
  END IF;
END;
/
PRO
-- end common
