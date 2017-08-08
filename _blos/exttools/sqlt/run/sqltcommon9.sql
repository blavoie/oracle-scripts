REM $Header: 215187.1 sqltcommon9.sql 11.4.5.7 2013/04/05 carlos.sierra $
-- begin common
SET TERM OFF;
CL COL;
EXEC DBMS_APPLICATION_INFO.SET_MODULE(module_name => NULL, action_name => NULL);
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => NULL);
UNDEF sqldx_prefix plicense sqldx_reports_format sqlid
UNDEF tool_repository_schema tool_administer_schema tool_version
UNDEF role_name temporary_or_permanent
UNDEF 1
UNDEF file_with_one_sql
UNDEF lib_count role_count connected_user
UNDEF statement_id unique_id spfile udump_path bdump_path traces_directory_path
UNDEF prev_sql_id prev_child_number
UNDEF filename
UNDEF explain_plan_for
UNDEF file_10046_10053_udump
SET DEF ON ESC OFF TERM ON ECHO OFF FEED 6 VER ON SHOW OFF HEA ON LIN 80 NEWP 1 PAGES 14 SQLC MIX TAB ON TRIMS OFF TI OFF TIMI OFF ARRAY 15 NUMF "" SQLP SQL> SUF sql BLO . RECSEP WR APPI OFF SERVEROUT OFF;
SET SQLBL OFF;
PRO
-- end common
